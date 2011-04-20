#!/usr/bin/env perl

use Test::More tests => 23;

use Scrappy;
my  $scrappy = Scrappy->new;

# scraper object
ok  'Scrappy' eq ref $scrappy;

# test stash in general
ok  $scrappy->stash('age' => 23);
ok  $scrappy->stash('age');
ok  $scrappy->stash('age') == 23;
ok  $scrappy->stash->{'age'};
ok  $scrappy->stash->{'age'} == 23;

# test stash using an array of numbers
my  @array = (1..20);
ok  $scrappy->stash('integers' => scalar @array);
ok  $scrappy->stash('integers');
ok  $scrappy->stash('integers') == 20;
ok  ! ref $scrappy->stash('integers'); # should NOT be an arrayref

# test stash using an arrayref
ok  $scrappy->stash('integers' => [@array]);
ok  $scrappy->stash('integers');
ok  @{$scrappy->stash('integers')} == 20;
ok  ref $scrappy->stash('integers'); # should be an arrayref

# test stash using multiple variables
ok  $scrappy->stash(@array);
ok  $scrappy->stash(@array)->{1};
ok  $scrappy->stash(@array)->{1} == 2;
ok  $scrappy->stash(@array)->{3} == 4;
ok  $scrappy->stash(@array)->{5} == 6;
ok  $scrappy->stash(@array)->{7} == 8;
ok  $scrappy->stash(@array)->{9} == '10';

# now, lets try to break it, NOT
ok  ! $scrappy->stash(sub{});
ok  $scrappy->stash(sub{} => 1);