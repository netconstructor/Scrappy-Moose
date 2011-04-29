package Scrappy::Action::Generate;

use   File::Util;
use   Moose::Role;
use   String::TT qw/tt strip/;
with 'Scrappy::Action::Help';

sub script {
    my  ($self, @options) = @_;
    my  $script_name = $options[0] || "myapp.pl";
        $script_name =~ s/\.pl$//;
    
    File::Util->new->write_file(
      'file'    => "$script_name.pl",
      'bitmask' => 0644,
      'content' => strip tt q{
        #!/usr/bin/perl
        
        use strict;
        use warnings;
        use Scrappy;
        
        my  $scraper  = Scrappy->new;
        my  $datetime = $scraper->logger->timestamp;
            $datetime =~ s/\D//g;
            
            # report warning, errors and other information
            $scraper->debug(0);
            
            # report detailed event logs
            $scraper->logger->verbose(0);
            
            # create a new log file with each execution
            $scraper->logger->write("[% script_name %]_logs/$datetime.yml")
                if $scraper->debug;
            
            # load session file for persistent storage between executions
            -f '[% script_name %].session' ?
                $scraper->session->load('[% script_name %].session') :
                $scraper->session->write('[% script_name %].session');
                
            # crawl something ...
            $scraper->crawl('http://localhost/',
                '/' => {
                    'body' => sub {
                        my ($self, $item, $params) = @_;
                        # ...
                    }
                }
            );
            
    });
    
    return "\n... successfully created script $script_name.pl\n";
}

sub project {
    my  ($self, @options) = @_;
    
    my  $project = $options[0] || "MyApp";
    my  $object  = lc $project;
    
    File::Util->new->write_file(
      'file'    => "$project/$object",
      'bitmask' => 0644,
      'content' => strip tt q{
        #!/usr/bin/perl
        
        use strict;
        use warnings;
        use lib 'lib';
        use [% project %];
        
        [% project %]->spider('http://www.[% object %].com/') ; # ... and away we go ...
    });
    
    File::Util->new->write_file(
      'file'    => "$project/lib/$project.pm",
      'bitmask' => 0644,
      'content' => strip tt q{
        package [% project %];

        use  Moose;
        use  Scrappy;
        with 'Scrappy::Project';
        
        sub setup {
            
            my  $[% object %] = shift;
            my  $scraper  = $[% object %]->scraper;
            my  $datetime = $scraper->logger->timestamp;
                $datetime =~ s/\D//g;
                
                # report warning, errors and other information
                $scraper->debug(0);
                
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
                $[% object %]->route('/' => 'page');
                
                # return your configured app instance
                $[% object %];
        
        }
        
        1;
    });
    
    File::Util->new->write_file(
      'file'    => "$project/lib/$project/Page.pm",
      'bitmask' => 0644,
      'content' => strip tt q{
        package [% project %]::Page;

        use Moose;
        with 'Scrappy::Project::Document';
        
        sub title {
            return
                shift->scraper->select('title')
                ->data->[0]->{text};
        }
        
        1;
    });
    
    return "\n... successfully created project $project\n";
}

1;

__DATA__

The generate action is use to generate various scaffolding (or boiler-plate code)
to reduce the tedium, get you up and running quicker and with more efficiency.

* Generate a Scrappy script

USAGE: scrappy generate script [FILENAME]
EXAMPLE: scrappy generate script eg/web_crawler.pl

* Generate a Scrappy project

USAGE: scrappy generate project [PACKAGE]
EXAMPLE: scrappy generate project MyApp
