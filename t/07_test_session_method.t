#!/usr/bin/env perl

use Test::More tests => 13;

use Scrappy;
my  $scraper = Scrappy->new;
my  $session = $scraper->session;

# test basic session method and functionality
ok  $session->stash('age' => 23);
ok  23 == $session->stash('age');
ok  23 == $session->stash('age');
ok  23 == $session->stash->{'age'};
ok  $session->stash('age' => 24);
ok  $session->write('t/session.yml');

my  $sessionx = Scrappy->new->session;

# read session file and modify it using new object
ok  $sessionx->load('t/session.yml');
ok  24 == $sessionx->stash('age');
ok  $sessionx->stash('age' => 25);

my  $sessionxx = Scrappy->new->session;

# read session file and test for changed age without explicit save/write
ok  $sessionxx->load('t/session.yml');
ok  25 == $sessionxx->stash('age');

# test session file loading
ok  $sessionxx->stash(':file' => 't/session.yml');
ok  25 == $sessionxx->stash('age');
