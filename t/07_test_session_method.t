#!/usr/bin/env perl

use Test::More tests => 13;

use Scrappy;
my  $scraper = Scrappy->new;

# test basic session method and functionality
ok  $scraper->session('age' => 23);
ok  23 == $scraper->session('age');
ok  23 == $scraper->session->stash('age');
ok  23 == $scraper->session->stash->{'age'};
ok  $scraper->session('age' => 24);
ok  $scraper->session->write('t/90_session.yml');

my  $new_scraper = Scrappy->new;

# read session file and modify it using new object
ok  $new_scraper->session->load('t/90_session.yml');
ok  24 == $new_scraper->session('age');
ok  $new_scraper->session('age' => 25);

my  $new_new_scraper = Scrappy->new;

# read session file and test for changed age without explicit save/write
ok  $new_new_scraper->session->load('t/90_session.yml');
ok  25 == $new_new_scraper->session('age');

# test session file loading
ok  $scraper->session(':file' => 't/90_session.yml');
ok  25 == $scraper->session('age');
