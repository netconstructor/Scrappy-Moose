#!/usr/bin/perl

use Scrappy; # new and improve ... with Moose and other styling gel

my  $scrappy = Scrappy->new;
    
# using the crawl method

    $scrappy->crawl('http://search.cpan.org/recent',
        '/recent' => {
            '#cpansearch li a' => sub {
                print $_[1]->{href}, "\n";
            }
        }
    );
    
print "Done\n";