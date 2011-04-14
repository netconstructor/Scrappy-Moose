# ABSTRACT: Scrappy Interactive Shell
package Scrappy::Console;

use 5.006;
use warnings;
use strict;
use App::Rad;
use Scrappy::Console::Util;
use Scrappy::Console::Command::HelpMenu;

BEGIN {
    use Exporter();
    use vars qw( @ISA @EXPORT @EXPORT_OK );
    @ISA    = qw( Exporter );
    @EXPORT = qw(shell);
}

=head1 SYNOPSIS

    ... from the command-line type
    
    scrappy
    
    -or-
    
    perl -MScrappy::Console -e shell


=cut

=method shell

An interactive console for Scrappy

=cut

sub shell {
    App::Rad->shell({
        title      => [<DATA>],
        prompt     => 's',
        autocomp   => 1,
        abbrev     => 1,
        ignorecase => 0,
        history    => 1, # or 'path/to/histfile.txt'
    });
}

sub main::setup {
    
    my $c = shift;
       $c->stash->{commands} = $c->{_commands};
       
    my $m = [
            {
                name => 'help',
                code => sub {
                    my $c = shift;
                    my $u = Scrappy::Console::Util->new;
                    my $h = Scrappy::Console::Command::HelpMenu->new;
                    
                    # display help document for a specific function
                    if (defined $c->argv->[0]) {
                        if (defined $c->{_commands}->{$c->argv->[0]}) {
                            return $h->display($c->argv->[0], $c);
                        }
                    }
                    
                    return $u->template('menus/commands.tt', $c);
                },
                help => 'display available commands.'
            },
            {
                name => 'menu',
                code => sub {
                    my $c = shift;
                    my $u = Scrappy::Console::Util->new;            
                    
                    return $u->template('menus/master.tt', $c);
                },
                help => 'display main menu.'            
            },
        ];
    
    $c->register( $_->{name}, $_->{code}, $_->{help} ) foreach @{$m};
        
    # register make commands
    #foreach my $cmd ( @{Scrappy::Console::Make->new($c)->{commands}} ) {
    #    my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
    #    $c->{_commands}->{$n}->{args} = $cmd->{args};
    #}
    
    # register data commands
    #foreach my $cmd ( @{Scrappy::Console::Data->new($c)->{commands}} ) {
    #    my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
    #    $c->{_commands}->{$n}->{args} = $cmd->{args};
    #}
    
    # register toolbox commands
    #foreach my $cmd ( @{Scrappy::Console::Tool->new($c)->{commands}} ) {
    #    my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
    #    $c->{_commands}->{$n}->{args} = $cmd->{args};
    #}
    
    # register MVC commands
    #foreach my $cmd ( @{Scrappy::Console::Mvc->new($c)->{commands}} ) {
    #    my $n = $c->register($cmd->{name}, $cmd->{code}, $cmd->{help});
    #    $c->{_commands}->{$n}->{args} = $cmd->{args};
    #}
        
    $c->{'_functions'}->{'invalid'} = sub {
        my $c = shift;
        my $u = Scrappy::Console::Util->new;            
        return $u->template('misc/error_string.tt', $c);
    };
}

1; 

__DATA__

Welcome to the Scrappy interactive console application.
This application should be primarily used to load; HTML
and grab; HTML elements using CSS and XPATH selectors for
testing and debugging purposes.

