#ABSTRACT: Common Functions For The Scrappy Console
package Scrappy::Console::Util;

use warnings;
use strict;

use Cwd qw(getcwd);
use File::ShareDir ':ALL';
use File::Util;
use Template;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

=method template

Load templates for terminal screen display.

=cut

sub template {
    my $self  = shift;
    my $file  = shift;
    my $stash = shift;
    my $t     = Template->new(
        EVAL_PERL => 1,
        ABSOLUTE  => 1,
        ANYCASE   => 1
    );
    my $content;

    $file = "templates/" . $file;
    $file = -e "share/$file" ? "share/$file" : dist_file('Scrappy', "$file");

    $t->process($file, {'s' => $stash}, \$content);

    return $content;
}

=method makefile

Create files under the current working directory.

=cut

sub makefile {
    my $self = shift;
    my @data = @_;
    my $f    = File::Util->new;
    $f->write_file(@data) unless -e $data[1];
}

1;
