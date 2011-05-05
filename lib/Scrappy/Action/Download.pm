package Scrappy::Action::Download;

use URI;
use Moose::Role;
use Scrappy;
with 'Scrappy::Action::Help';

sub page {
    my  ( $self, @options ) = @_;

    my  $url = $options[0];
    die "Can't download a page without a proper URL"
      unless $url;
    $url = URI->new($url);

    my  $scraper = Scrappy->new;
    $scraper->debug(1);
    $scraper->logger->write('download.log');

    my  $downloader = {
        '//link[@href]' => sub {
            my ( $self, $item, $params ) = @_;

            if ( $item->{href} ) {
                if (   $item->{href} =~ m{^$url}
                    || $item->{href} !~ m/^http(s)?\:\/\// )
                {

                    $item->{href} = URI->new_abs( $item->{href}, $url )
                      if $item->{href} !~ m/^http(s)?\:\/\//;

                    $self->download( $item->{href} );

                    # assuming its a css stylesheet, lets see if we find
                    # any images that need downloading
                    # HACK AHHHHHHHHHHHHHHH !!!!!!!!!
                    if ( $self->get( $item->{href} )->page_loaded ) {

                        if ( $self->content ) {

                            $self->content->decode;
                            my @urls =
                            $self->content->as_string =~
                            /url\s{0,}?\(?[\'\"\s]{0,}?([^\)]+)?[\'\"\s]{0,}?\)/g;

                            if (@urls) {

                                # download any found urls (probably images)
                                foreach my $url (@urls) {
                                    $url =~ s/^\s+//g;
                                    $url =~ s/\s+$//g;
                                    $url =~ s/[\'\"]//g;
                                    $url !~ m/^http(s)?\:\/\//
                                      ? $self->download(
                                        URI->new_abs( $url, $item->{href} ) )
                                      : $self->download($url);
                                }
                            }
                        }
                    }
                }
            }
        },
        '//script[@src]' => sub {
            my ( $self, $item, $params ) = @_;
            if ( $item->{src} ) {

                $item->{src} = URI->new_abs( $item->{src}, $url )
                  if $item->{src} !~ m/^http(s)?\:\/\//;

                $self->download( $item->{src} )
                  if $item->{src} =~ m{^$url}
                      || $item->{src} !~ m/^http(s)?\:\/\//;
            }
        },
        '//img[@src]' => sub {
            my ( $self, $item, $params ) = @_;
            if ( $item->{src} ) {

                $item->{src} = URI->new_abs( $item->{src}, $url )
                  if $item->{src} !~ m/^http(s)?\:\/\//;

                $self->download( $item->{src} )
                  if $item->{src} =~ m{^$url}
                      || $item->{src} !~ m/^http(s)?\:\/\//;
            }
        },
    };

    $scraper->crawl($url,
        '/'  => $downloader,
        '/*' => $downloader
    );

    if ( $scraper->get($url)->page_loaded ) {

        my $filename = $scraper->worker->response->filename || 'index.html';
        $scraper->store($filename);
        return "\n... successfully downloaded $filename and it's assets\n";

    }

    return "\n... downloading may have had some trouble, see download.log\n";

}

1;

__DATA__

The download action is use to download html pages and/or assets from the
Internet for various reasons, e.g. backing up HTML pages, etc.

* Download a web page and all images, scripts and stylesheets

USAGE: scrappy download page [URL]
EXAMPLE: scrappy download page http://search.cpan.org/
