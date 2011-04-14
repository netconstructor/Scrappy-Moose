#!/usr/bin/env perl

use Test::More tests => 32;

use Scrappy;
my  $scraper = Scrappy->new;

# test queue method
ok 'Scrappy::Queue' eq ref $scraper->queue;
ok 0 == scalar $scraper->queue->list;
ok 1 == scalar $scraper->queue('http://google.com')->list;
ok 2 == scalar $scraper->queue('http://aol.com')->list;
ok 3 == scalar $scraper->queue('http://www.msn.com')->list;

# test queue uniqueness
ok 3 == scalar $scraper->queue('http://www.msn.com')->list;
ok 3 == scalar $scraper->queue('http://www.msn.com')->list;
ok 3 == scalar $scraper->queue('http://www.msn.com')->list;

# test queue validation
ok 4 == scalar $scraper->queue('http://duckduckgo.com')->list;
ok 4 == scalar $scraper->queue('123456789')->list;
ok 4 == scalar $scraper->queue('')->list;
ok 4 == scalar $scraper->queue(' ')->list;
ok 4 == scalar $scraper->queue('.ww')->list;
ok 4 == scalar $scraper->queue('w.w')->list;
ok 5 == scalar $scraper->queue('wy.me')->list;

# test reset
ok 0 == scalar $scraper->queue->clear->list;

# test queue add method seperately
ok 1 == scalar $scraper->queue->add('http://www.cbs.com')->list;
ok 2 == scalar $scraper->queue->add('http://www.msn.com')->list;
ok 3 == scalar $scraper->queue->add('http://www.nbc.com')->list; 

# test next method
ok 'http://www.cbs.com' eq $scraper->queue->next;
ok 'http://www.msn.com' eq $scraper->queue->next;
ok 'http://www.nbc.com' eq $scraper->queue->next;
ok ! $scraper->queue->next;

# test reset method
ok $scraper->queue->reset;
ok 'http://www.cbs.com' eq $scraper->queue->reset->next;

# test first and last methods
ok 'http://www.cbs.com' eq $scraper->queue->first;
ok 'http://www.nbc.com' eq $scraper->queue->last;

# test previous method
ok 'http://www.msn.com' eq $scraper->queue->previous;
ok 'http://www.cbs.com' eq $scraper->queue->previous;

# test index, current and cursor methods
ok 'http://www.msn.com' eq $scraper->queue->index(1);
ok 'http://www.msn.com' eq $scraper->queue->current;
ok 'http://www.msn.com' eq $scraper->queue->index($scraper->queue->cursor);
