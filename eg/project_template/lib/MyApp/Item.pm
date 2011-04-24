package MyApp::Item;

use Moose;
with 'Scrappy::Project::Document';

sub title {
    
    my $scraper = shift->scraper;
    $scraper->log('info', 'found page ... ' . 
    $scraper
    ->select('title')
    ->data->[0]->{text} );
}

1;