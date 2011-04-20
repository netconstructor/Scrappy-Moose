#!/usr/bin/env perl

use Test::More tests => 32;

use Scrappy;
my  $scraper = Scrappy->new;
my  $queue = $scraper->queue;

# test queue method
ok 'Scrappy::Queue' eq ref $queue;
ok 0 == scalar $queue->list;
ok 1 == scalar $queue->add('http://google.com')->list;
ok 2 == scalar $queue->add('http://aol.com')->list;
ok 3 == scalar $queue->add('http://www.msn.com')->list;

# test queue uniqueness
ok 3 == scalar $queue->add('http://www.msn.com')->list;
ok 3 == scalar $queue->add('http://www.msn.com')->list;
ok 3 == scalar $queue->add('http://www.msn.com')->list;

# test queue validation
ok 4 == scalar $queue->add('http://duckduckgo.com')->list;
ok 4 == scalar $queue->add('123456789')->list;
ok 4 == scalar $queue->add('')->list;
ok 4 == scalar $queue->add(' ')->list;
ok 4 == scalar $queue->add('.ww')->list;
ok 4 == scalar $queue->add('w.w')->list;
ok 5 == scalar $queue->add('wy.me')->list;

# test reset
ok 0 == scalar $queue->clear->list;

# test queue add method seperately
ok 1 == scalar $queue->add('http://www.cbs.com')->list;
ok 2 == scalar $queue->add('http://www.msn.com')->list;
ok 3 == scalar $queue->add('http://www.nbc.com')->list; 

# test next method
ok 'http://www.cbs.com' eq $queue->next;
ok 'http://www.msn.com' eq $queue->next;
ok 'http://www.nbc.com' eq $queue->next;
ok ! $queue->next;

# test reset method
ok $queue->reset;
ok 'http://www.cbs.com' eq $queue->reset->next;

# test first and last methods
ok 'http://www.cbs.com' eq $queue->first;
ok 'http://www.nbc.com' eq $queue->last;

# test previous method
ok 'http://www.msn.com' eq $queue->previous;
ok 'http://www.cbs.com' eq $queue->previous;

# test index, current and cursor methods
ok 'http://www.msn.com' eq $queue->index(1);
ok 'http://www.msn.com' eq $queue->current;
ok 'http://www.msn.com' eq $queue->index($queue->cursor);
