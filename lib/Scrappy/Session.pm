# ABSTRACT: Scrappy Scraper Session Handling
# Dist::Zilla: +PodWeaver

package Scrappy::Session;

# load OO System
use Moose;

# load other libraries
use Carp;
use YAML::Syck;
$YAML::Syck::ImplicitTyping = 1;

has 'auto_save' => (is => 'rw', isa => 'Bool', default => 1);
has 'file' => (is => 'rw', isa => 'Str');

=head1 SYNOPSIS

    #!/usr/bin/perl
    use Scrappy::Session;

    my  $session = Scrappy::Session->new;
    
        -f 'scraper.sess' ?
        $session->load('scraper.sess');
        $session->write('scraper.sess');
        
        $session->stash('foo' => 'bar');
        $session->stash('abc' => [('a'..'z')]);
        
=head1 DESCRIPTION

Scrappy::Session provides YAML-Based session file handling for saving recorded
data across multiple execution using the L<Scrappy> framework.

=head2 ATTRIBUTES

The following is a list of object attributes available with every Scrappy::Session
instance.

=head3 auto_save

The auto_save attribute is a boolean that determines whether stash data is
automatically saved to the session file on update.

    my  $session = Scrappy::Session->new;
        
        $session->load('scraper.sess');
        $session->stash('foo' => 'bar');
        
        # turn auto-saving off
        $session->auto_save(0);
        $session->stash('foo' => 'bar');
        $session->write; # explicit write
        
=head3 file

The file attribute gets/sets the filename of the current session file.

    my  $session = Scrappy::Session->new;
        
        $session->load('scraper.sess');
        $session->write('scraper.sess.bak');
        $session->file('scraper.sess');
        
=method load

The load method is used to read-in a session file, it returns its data in the
structure it was saved-in.

    my  $session = Scrappy::Session->new;
    my  $data = $session->load('scraper.sess');

=cut

sub load {
    my $self = shift;
    my $file = shift;

    if ($file) {

        $self->file($file);

        croak("Session file $file does not exist or is not read/writable")
          unless -f $file;

        # load session file
        $self->{stash} = LoadFile($file);
    }

    return $self->{stash};
}

=method stash

The stash method accesses the stash object which is used to store data to be
written to the session file.

    my  $session = Scrappy::Session->new;
        $session->load('scraper.sess');
        
        $session->stash('foo' => 'bar');
        $session->stash('abc' => [('a'..'z')]);
        $session->stash->{123} = [(1..9)];

=cut

sub stash {
    my $self = shift;
    $self->{stash} = {} unless defined $self->{stash};

    if (@_) {
        my $stash = @_ > 1 ? {@_} : $_[0];
        if ($stash) {
            if (ref $stash eq 'HASH') {
                for (keys %{$stash}) {
                    if (lc $_ ne ':file') {
                        $self->{stash}->{$_} = $stash->{$_};
                    }
                    else {
                        $self->{file} = $stash->{$_};
                    }
                }
            }
            else {
                return $self->{stash}->{$stash};
            }
        }
    }

    $self->auto_write;
    return $self->{stash};
}

=method write

The write method is used to write-out a session file, it saves the data stored
in the session stash and it returns the data written upon completion.

    my  $session = Scrappy::Session->new;
    
        $session->stash('foo' => 'bar');
        $session->stash('abc' => [('a'..'z')]);
        $session->stash->{123} = [(1..9)];
    
    my  $data = $session->write('scraper.sess');

=cut

sub write {
    my $self = shift;
    my $file = shift || $self->file;

    $self->file($file);

    if ($file) {

        # write session file
        DumpFile($file, $self->{stash});
        
        # ... ummm
        croak("Session file $file does not exist or is not read/writable")
          unless -f $file;
    }

    return $self->{stash};
}

sub auto_write {
    my  $self = shift;
        $self->write if $self->auto_save;
        
    return $self;
}

1;
