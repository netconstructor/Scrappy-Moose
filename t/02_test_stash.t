#!/usr/bin/env perl

use Test::More tests => 22;

use Scrappy;
my  $scraper = Scrappy->new;

# test stash in general
ok  $scraper->stash('age' => 23);
ok  $scraper->stash('age');
ok  $scraper->stash('age') == 23;
ok  $scraper->stash->{'age'};
ok  $scraper->stash->{'age'} == 23;

# test stash using an array of numbers
my  @array = (1..20);
ok  $scraper->stash('integers' => scalar @array);
ok  $scraper->stash('integers');
ok  $scraper->stash('integers') == 20;
ok  ! ref $scraper->stash('integers'); # should NOT be an arrayref

# test stash using an arrayref
ok  $scraper->stash('integers' => [@array]);
ok  $scraper->stash('integers');
ok  @{$scraper->stash('integers')} == 20;
ok  ref $scraper->stash('integers'); # should be an arrayref

# test stash using multiple variables
ok  $scraper->stash(@array);
ok  $scraper->stash(@array)->{1};
ok  $scraper->stash(@array)->{1} == 2;
ok  $scraper->stash(@array)->{3} == 4;
ok  $scraper->stash(@array)->{5} == 6;
ok  $scraper->stash(@array)->{7} == 8;
ok  $scraper->stash(@array)->{9} == '10';

# now, lets try to break it, NOT
ok  ! $scraper->stash(sub{});
ok  $scraper->stash(sub{} => 1);