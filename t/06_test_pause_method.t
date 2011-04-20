#!/usr/bin/env perl

use Test::More tests => 19;

use Scrappy;
my  $scrappy = Scrappy->new;

# test pause method
ok 0 == $scrappy->pause;
ok $scrappy->pause(20);
ok 20 == $scrappy->pause(20);
ok 20 == $scrappy->pause;
ok $scrappy->pause(5,20);

ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok $scrappy->pause >= 5 && $scrappy->pause <= 20;
ok defined $scrappy->pause(0);
ok defined $scrappy->pause;
ok ! $scrappy->pause;

# warn $scrappy->pause;