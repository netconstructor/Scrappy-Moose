package MyApp;

use  Moose;
use  Scrappy;
with 'Scrappy::Project';

sub setup {
    
    my  $myapp    = shift;
    my  $scraper  = $myapp->scraper;
    my  $datetime = $scraper->logger->timestamp;
        $datetime =~ s/\D//g;
        
        # report warning, errors and other information
        $scraper->debug(1);
        
        # report detailed event logs
        $scraper->logger->verbose(0);
        
        # create a new log file with each execution
        $scraper->logger->write("logs/$datetime.yml")
            if $scraper->debug;
        
        # load session file for persistent storage between executions
        -f 'session.yml' ?
            $scraper->session->load('session.yml') :
            $scraper->session->write('session.yml');
            
        # define route(s) - route web pages to parsers
        $myapp->route('/' => 'item');
        
        # return your configured app instance
        $myapp;

}

1;