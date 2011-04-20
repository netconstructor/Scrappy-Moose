#!/usr/bin/env perl

use Test::More tests => 26;

use Scrappy;
my  $scrappy = Scrappy->new;
my  $useragent = $scrappy->user_agent;

# scraper object
ok  'Scrappy::Scraper::UserAgent' eq ref $useragent;

# test user-agent in general
ok $useragent->name('My-User-Agent');
ok $useragent->name eq 'My-User-Agent';

# test random user-agent method
ok $useragent->random_user_agent;
ok $useragent->random_user_agent('any');
ok $useragent->random_user_agent('chrome');
ok $useragent->random_user_agent('explorer');
ok $useragent->random_user_agent('opera');
ok $useragent->random_user_agent('safari');
ok $useragent->random_user_agent('firefox');

# test random user-agent for linux
ok $useragent->random_user_agent('chrome', 'linux') =~ /Linux/;
ok ! $useragent->random_user_agent('explorer', 'linux'); # should fail, linux deosnt support explorer silly :P
ok $useragent->random_user_agent('opera', 'linux') =~ /Linux/;
ok $useragent->random_user_agent('safari', 'linux') =~ /Linux/;
ok $useragent->random_user_agent('firefox', 'linux') =~ /Linux/;

# test random user-agent for windows
ok $useragent->random_user_agent('chrome', 'windows') =~ /Windows/;
ok $useragent->random_user_agent('explorer', 'windows') =~ /Windows/;
ok $useragent->random_user_agent('opera', 'windows') =~ /Windows/;
ok $useragent->random_user_agent('safari', 'windows') =~ /Windows/;
ok $useragent->random_user_agent('firefox', 'windows') =~ /Windows/;

# test random user-agent for macintosh
ok $useragent->random_user_agent('chrome', 'macintosh') =~ /Mac/;
ok $useragent->random_user_agent('explorer', 'macintosh') =~ /Mac/;
ok $useragent->random_user_agent('opera', 'macintosh') =~ /Mac/;
ok $useragent->random_user_agent('safari', 'macintosh') =~ /Mac/;
ok $useragent->random_user_agent('firefox', 'macintosh') =~ /Mac/;
ok $useragent->name =~ /Mac/;
