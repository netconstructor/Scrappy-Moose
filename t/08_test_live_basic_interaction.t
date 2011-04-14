#!/usr/bin/env perl

use Test::More tests => 4;

use Scrappy;
my  $scr8r1 = Scrappy->new;
    $scr8r1->random_user_agent;

# fetch google.com homepage
ok  $scr8r1->get('http://google.com');
ok  $scr8r1->session->write('t/99_session.yml');

my  $scr8r2 = Scrappy->new;
    $scr8r2->random_user_agent;
    
# 
ok  $scr8r2->session(':file' => 't/99_session.yml');
ok  keys %{$scr8r2->session->stash('cookies')};