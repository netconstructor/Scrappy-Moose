#!/usr/bin/env perl

use Test::More tests => 19;

use Scrappy;
my  $scraper = Scrappy->new;

# test pause method
ok 0 == $scraper->pause;
ok $scraper->pause(20);
ok 20 == $scraper->pause(20);
ok 20 == $scraper->pause;
ok $scraper->pause(5,20);

ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok $scraper->pause >= 5 && $scraper->pause <= 20;
ok defined $scraper->pause(0);
ok defined $scraper->pause;
ok ! $scraper->pause;

# warn $scraper->pause;