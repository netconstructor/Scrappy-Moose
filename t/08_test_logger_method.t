#!/usr/bin/env perl

use Test::More tests => 15;

use Scrappy;
my  $scraper = Scrappy->new;
my  $logger = $scraper->logger;
my  $loggerx = Scrappy->new->logger;

# test object
ok  'Scrappy::Logger' eq ref $logger;

# test basic logger method and functionality
ok  $logger->load('t/log.yml') if -f 't/log.yml';
ok  $logger->info('Captains log, stardate 123456');
ok  $logger->info('Backwards me, whereami 987654', foo => 'bar');
ok  $logger->write('t/log.yml');

# test reload and continue
ok  $loggerx->load('t/log.yml');
ok  $loggerx->error('Great scotts, something strange has happened here');
ok  $loggerx->warn('This is not a drill');
ok  $loggerx->event('custom', 'User-defined error message here', ('a'..'l'));

# test verbosity
ok  $loggerx->load('t/log.yml');
ok  $loggerx->info('Verbosity information');
ok  $loggerx->error('Verbosity error message');
ok  $loggerx->warn('Verbosity warning');
ok  $loggerx->verbose(1);
ok  $loggerx->event('custom', 'Verbosity event', ('a'..'l'));