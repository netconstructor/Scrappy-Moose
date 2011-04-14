#ABSTRACT: Scrappy Console Command Base Class
package Scrappy::Console::Command;

use strict;
use warnings;

use Scrappy::Console::Util;
use Scrappy::Console::Help;

sub new {
    my ($class, $s)     = @_;
    my $self            = {};
    
    $self->{util} = Scrappy::Console::Util->new;
    $self->{help} = Scrappy::Console::Help->new;
    
    bless $self, $class;
    return $self;
}

1;