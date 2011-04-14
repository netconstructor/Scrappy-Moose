# ABSTRACT: Scrappy Recorder and Session Management

package Scrappy::Session;

# load OO System
use Moose;

# load other libraries
use Carp;
use YAML::Syck;
    $YAML::Syck::ImplicitTyping = 1;

=head1 SYNOPSIS

    #!/usr/bin/perl
    use Scrappy;

    my  $scraper = Scrappy->new;
        $scraper->session->load('file.yml');
        
        $scraper->stash('foo' => 123); # writes back to file.yml automatically
        $scraper->write('file.backup.yml');

=head1 DESCRIPTION

Scrappy::Session provides Scrappy with methods for storing stash and cookie data
in a session (YAML) file for sharing important data across executions.

=cut

=method load

The load method is used to read the specified session file.

    my  $session = Scrappy::Session->new;
    my  $data = $session->load('session.yml');

=cut

sub load {
    my  $self = shift;
    my  $file = shift;
    
    if ($file) {
        
        $self->{file}  = $file;
        
        # load session file
        $self->{stash} = LoadFile($file)
            or croak("Session file $file does not exist or is not read/writable");
    }
    
    return $self->{stash};
}

=method stash

The stash method sets a stash (shared) variable or returns a reference to the entire
stash object.

    my  $session = Scrappy::Session->new;
        $session->stash(age => 31);
        
    print 'stash access works'
        if $session->stash('age') == $session->stash->{age};
    
    my @array = (1..20);
    $session->stash(integers => [@array]);
    
=cut

sub stash {
    my  $self = shift;
        $self->{stash} = {} unless defined $self->{stash};
    
    if (@_) {
        my  $stash = @_ > 1 ? {@_} : $_[0];
        if($stash) {
            if (ref $stash eq 'HASH') {
                $self->{stash}->{$_} = $stash->{$_} for keys %{$stash};
            }
            else {
                return $self->{stash}->{$stash};
            }
        }
    }
    
    return $self->{stash};
}

=method write

The write method is used to write the specified session file.

    my  $session = Scrappy::Session->new;
        $session->write('file.yml');

=cut

sub write {
    my  $self = shift;
    my  $file = shift || $self->{file};
    
    if ($file) {
        # write session file
        DumpFile($file, $self->{stash})
            or croak("Session file $file does not exist or is not read/writable");
    }
    
    return $self->{stash};
}

1;