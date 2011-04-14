#!/usr/bin/env perl

use Test::More tests => 8;

use Scrappy;
my  $scraper = Scrappy->new;

# test allowed_domains in general
ok ! @{ $scraper->allowed_domains };
ok ref $scraper->allowed_domains;
ok $scraper->allowed_domains('http://google.com');
ok 'google.com' eq $scraper->allowed_domains->[0];
ok $scraper->allowed_domains('www.google.com', 'aol.com', 'www.msn.com');
ok 'www.google.com' eq $scraper->allowed_domains->[0];
ok 'aol.com' eq $scraper->allowed_domains->[1];
ok 'www.msn.com' eq $scraper->allowed_domains->[2];
