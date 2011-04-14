#!/usr/bin/env perl

use Test::More tests => 5;

# load Scrappy
use_ok 'Scrappy';
my  $scraper = Scrappy->new;

# init Scrappy object
ok ref($scraper);

# test WWW::Mechanize object
ok $scraper->mech;
ok ref($scraper->mech);
ok ref($scraper->mech) eq 'WWW::Mechanize';