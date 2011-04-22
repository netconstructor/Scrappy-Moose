use Pod::Simple::HTML;

my  $p = Pod::Simple::HTML->new;
    $p->output_string(\my $html);
    $p->parse_file('lib/Scrappy.pm');

open
    my $out, '>', 'perlpod_scrappy.html'
        or die "Cannot open 'perlpod_scrappy.html': $!\n";

print $out $html;