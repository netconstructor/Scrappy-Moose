#ABSTRACT: Help Documentation For The Scrappy Console
package Scrappy::Console::Command::HelpMenu;

use warnings;
use strict;

use base 'Scrappy::Console::Command';

=method display

Show help screen for a given command or topic.

=cut

sub display {
    my $self = shift;
    my ($cmd, $c) = @_;
    
    if (defined $c->{_commands}->{$cmd}) {
        return $self->{util}->template("commands/help/$cmd"."_help.tt", $c);
    }
    else {
        return $self->{help}->error("Sorry, cannot find help for $cmd.")->report($c);
    }
}

1;