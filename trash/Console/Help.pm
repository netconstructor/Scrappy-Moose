#ABSTRACT: Error Handling for Scrappy Console
package Scrappy::Console::Help;

use warnings;
use strict;

use Scrappy::Console::Util;

sub new {
    my ($class, $s) = @_;
    my $self = {};
    bless $self, $class;
    $self->{base}   = $s;
    $self->{errors} = [];
    return $self;
}

=method error

The error method is responsible for storing passed in error messages for later
retrieval and rendering.

=cut

sub error {
    my $self = shift;
    foreach my $message (@_) {
        push @{$self->{errors}}, $message;
    }
    return $self;
}

=method count

The count method returns the number of error messages currently existing in the
error messages container.

=cut

sub count {
    return @{shift->{errors}};
}

=method clear

The clear method resets the error message container.

=cut

sub clear {
    shift->{errors} = [];
}

=method report

The report method is responsible for displaying all stored error
messages using the defined message delimiter.

=cut

sub report {
    my $self = shift;
    my $c    = shift;
    my $u    = Scrappy::Console::Util->new;
    if ($c) {
        $c->stash->{errors} = $self->{errors};
        $self->clear;
        return $u->template('misc/error_string.tt', $c);
    }
}

1;
