#!/usr/bin/env perl

use Test::More tests => 8;

use Scrappy;
my  $scrappy = Scrappy->new;
my  $control = $scrappy->control;

# control object
ok  'Scrappy::Scraper::Control' eq ref $control;

# test permissions in general
ok  1 == $control->allow('google.com');
ok  2 == $control->allow('google.com', 'cpan.org');
ok  ! $control->allow();
ok  $control->is_allowed('google.com');
ok  ! $control->is_allowed('google');
ok  1 == $control->restrict('google.com');
ok  ! $control->is_allowed('google.com');