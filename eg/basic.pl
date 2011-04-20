#!/usr/bin/perl
use Scrappy;

my $scraper = Scrappy->new;
my $q       = $scraper->queue;

$scraper->session->write('eg/session.yml');
$scraper->logger->write('eg/log.yml');

$q->add('http://search.cpan.org/recent'); # starting url

while (my $url = $q->next) {
    
    $scraper->get($url);
    
    # gather recent modules
    if ($scraper->page_match('/recent')) {
        
        print "... getting recent modules from $url\n";
        
        foreach my $link (@{ $scraper->select('#cpansearch li a')->data }) {
            $q->add($link->{href});
        }
    }
    
    # gather module information
    my $module = $scraper->page_match('/~:author/:name-:version/');
    if ($module) {
        
        my $reviews = $scraper
        ->select('.box table tr')->focus(3)->select('td.cell small a')
        ->data->[0]->{text};
        
        $reviews = $reviews =~ /\d+ Reviews/ ?
            $reviews : '0 reviews';
        
        print "found $module->{name} version $module->{version} ".
            "[$reviews] by $module->{author}\n";
        
    }
}