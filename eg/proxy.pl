#!/usr/bin/perl

use Scrappy; # new and improve ... with Moose and other styling gel

my  $scrappy = Scrappy->new;
    
    $scrappy->logger->verbose(1);
    $scrappy->logger->write('eg/proxy.log');
    
    # using the plugin system and the RandomProxy plugin
    
    $scrappy->plugin('random_proxy');
    
    #$scrappy->get('http://google.com/');
    
    print '... using proxy ' . $scrappy->use_random_proxy->proxy_address;