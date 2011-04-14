#!/usr/bin/env perl

use Test::More tests => 26;

use Scrappy;
my  $scraper = Scrappy->new;

# test user-agent in general
ok $scraper->user_agent('My-User-Agent');
ok $scraper->user_agent eq 'My-User-Agent';
ok 'My-User-Agent' eq $scraper->mech->agent;

# test random user-agent method
ok $scraper->random_user_agent;
ok $scraper->random_user_agent('any');
ok $scraper->random_user_agent('chrome');
ok $scraper->random_user_agent('explorer');
ok $scraper->random_user_agent('opera');
ok $scraper->random_user_agent('safari');
ok $scraper->random_user_agent('firefox');

# test random user-agent for linux
ok $scraper->random_user_agent('chrome', 'linux') =~ /Linux/;
ok $scraper->random_user_agent('explorer', 'linux') =~ /Linux/;
ok $scraper->random_user_agent('opera', 'linux') =~ /Linux/;
ok $scraper->random_user_agent('safari', 'linux') =~ /Linux/;
ok $scraper->random_user_agent('firefox', 'linux') =~ /Linux/;

# test random user-agent for windows
ok $scraper->random_user_agent('chrome', 'windows') =~ /Windows/;
ok $scraper->random_user_agent('explorer', 'windows') =~ /Windows/;
ok $scraper->random_user_agent('opera', 'windows') =~ /Windows/;
ok $scraper->random_user_agent('safari', 'windows') =~ /Windows/;
ok $scraper->random_user_agent('firefox', 'windows') =~ /Windows/;

# test random user-agent for macintosh
ok $scraper->random_user_agent('chrome', 'macintosh') =~ /Mac/;
ok $scraper->random_user_agent('explorer', 'macintosh') =~ /Mac/;
ok $scraper->random_user_agent('opera', 'macintosh') =~ /Mac/;
ok $scraper->random_user_agent('safari', 'macintosh') =~ /Mac/;
ok $scraper->random_user_agent('firefox', 'macintosh') =~ /Mac/;
ok $scraper->user_agent =~ /Mac/;
