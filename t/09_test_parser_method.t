#!/usr/bin/env perl

use Test::More tests => 5;

use Scrappy;
my  $html = <<HTML;
<TABLE border="2"
    summary="This table gives some statistics about fruit
             flies: average height and weight, and percentage
             with red eyes (for both males and females).">
<CAPTION><EM>A test table with merged cells</EM></CAPTION>
<TR><TH rowspan="2"><TH colspan="2">Average
    <TH rowspan="2">Red<BR>eyes
<TR><TH>height<TH>weight
<TR><TH>Males<TD>1.9<TD>0.003<TD>40%
<TR><TH>Females<TD>1.7<TD>0.002<TD>43%
</TABLE>
HTML

my  $parser = sub { my $i = Scrappy->new->parser; $i->html($html); $i };

# test $parser object
ok  'CODE' eq ref $parser;

# test basic parser method and functionality
ok  $parser->()
    ->scrape('table')
    ->[0]->{border} == 2;

ok  $parser->()
    ->select('table tr')->focus
    ->scrape('th')->[2]->{text} =~ 'Redeyes';

ok  $parser->()
    ->scrape('table tr td')
    ->[0]->{text} =~ '1\.9';

ok  $parser->()
    ->scrape('table caption em')
    ->[0]->{text} eq 'A test table with merged cells';
    
#warn join "\n", @{ $parser->()->select('table tr')->focus(3)->data };
