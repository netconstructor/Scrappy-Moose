#!/usr/bin/perl

use Scrappy;

my  $scrappy = Scrappy->new;

    $scrappy->pause(5, 20);

    $scrappy->logger->load('eg/basic/readme.log');
    $scrappy->session->load('eg/basic/readme.sess');
    
    $scrappy->get($_) for qw{
        http://www.google.com
        http://www.msn.com
        http://www.aol.com
    };
    
    print 'Done';