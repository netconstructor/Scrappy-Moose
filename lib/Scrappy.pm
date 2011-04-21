# ABSTRACT: All Powerful Web Spidering, Scrapering, Crawling Framework
# Dist::Zilla: +PodWeaver
package Scrappy;

# load OO System
use Moose;

# load other libraries
use Carp;
extends 'Scrappy::Scraper';

=head1 SYNOPSIS

    #!/usr/bin/perl
    use Scrappy;

    my  $scraper = Scrappy->new;
        $scraper->crawl('search.cpan.org',
            '/recent' => {
                '#cpansearch li a' => sub {
                    print $_[1]->{href}, "\n";
                }
            }
        );

=head1 DESCRIPTION

Scrappy is an easy (and hopefully fun) way of scraping, spidering, and/or
harvesting information from web pages, web services, and more. Scrappy is a
feature rich, flexible, intelligent web automation tool.

Scrappy (pronounced Scrap+Pee) == 'Scraper Happy' or 'Happy Scraper'; If you
like you may call it Scrapy (pronounced Scrape+Pee) although Python has a web
scraping framework by that name and this module is not a port of that one.

=cut

=method crawl

The crawl method is very useful when it is desired to crawl an entire website or
at-least partially, it automates the tasks of creating a queue, fetching and
parsing html pages, and establishing simple flow-control. See the SYNOPSIS for
a simplified example, ... the following is a more complex example.

    my  $scrappy = Scrappy->new;
    
    $scrappy->crawl('http://search.cpan.org/recent',
        '/recent' => {
            
            '#cpansearch li a' => sub {
                my ($self, $item) = @_;
                # follow all recent modules from search.cpan.org
                $self->queue->add($item->{href});
            }
            
        },
        '/~:author/:name-:version/' => {
            
            'body' => sub {
                my ($self, $item, $args) = @_;
                
                my $reviews = $self
                ->select('.box table tr')->focus(3)->select('td.cell small a')
                ->data->[0]->{text};
                
                $reviews = $reviews =~ /\d+ Reviews/ ?
                    $reviews : '0 reviews';
                
                print "found $args->{name} version $args->{version} ".
                    "[$reviews] by $args->{author}\n";
                
            }
            
        }
    );

=cut

sub crawl {
    my ($self, $starting_url, %pages) = @_;

    croak(
        'Please provide a starting URL and a valid configuration before crawling'
    ) unless ($self && $starting_url && keys %pages);

    # register the starting url
    $self->queue->add($starting_url);

    # start the crawl loop
    while (my $url = $self->queue->next) {

        # check if the url matches against any registered pages
        foreach my $page (keys %pages) {
            my $data = $self->page_match($page, $url);

            if ($data) {

                # found a page match, fetch and scrape the page for data
                $self->get($url);

                foreach my $selector (keys %{$pages{$page}}) {

                    # loop through resultset
                    foreach my $item (@{$self->select($selector)->data}) {

                        # execute selector code
                        $pages{$page}->{$selector}->($self, $item, $data);
                    }
                }
            }
        }
    }
}

1;
