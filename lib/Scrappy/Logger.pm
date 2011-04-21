# ABSTRACT: Scrappy Event Logging Mechanism
# Dist::Zilla: +PodWeaver
package Scrappy::Logger;

# load OO System
use Moose;

# load other libraries
use Carp;
use DateTime;
use DateTime::Format::SQLite;
use YAML::Syck;
$YAML::Syck::ImplicitTyping = 1;

has verbose => (is => 'rw', isa => 'Int', default => 0);

=head1 SYNOPSIS

    #!/usr/bin/perl
    use Scrappy;

    my  $log = Scrappy::Logger->new;
        $log->write('log.yml');
        
        $scraper->info('captain log, star-date 1234');
        $scraper->info('captain log, star-date 5678', foo => 'bar');
        $scraper->warn('...');
        $scraper->error('...');

=head1 DESCRIPTION

Scrappy::Logger provides Scrappy with methods for logging event data within
a easily readable log (YAML) files.

=cut

=method load

The load method is used to read the specified log file.

    my  $log = Scrappy::Logger->new;
    my  $data = $log->load('log.yml');

=cut

sub load {
    my $self = shift;
    my $file = shift;

    if ($file) {

        $self->{file} = $file;

        # load session file
        $self->{stash} = LoadFile($file)
          or croak("Log file $file does not exist or is not read/writable");
    }

    return $self->{stash};
}

=method timestamp

The timestamp method is used generate a current system date and time string for
use with event logging.

    my  $log  = Scrappy::Logger->new;
    my  $date = $log->timestamp;
    print $date;
    
    my $datetime_object = $log->timestamp($date);

=cut

sub timestamp {
    my $self = shift;
    my $date = shift;

    if ($date) {

        # $date =~ s/\_/ /g;
        return DateTime::Format::SQLite->parse_datetime($date)
          ;    # datetime object
    }
    else {
        $date =
          DateTime::Format::SQLite->format_datetime(DateTime->now);    # string

        # $date =~ s/ /_/g;
        return $date;
    }
}

=method info

The info method is used to log an information event to the event log.

    my  $log  = Scrappy::Logger->new;
    my  %data = ( foo => 'bar');
        $log->info('Something strange happened today', %data);
    
=cut

sub info {
    return shift->event('info', @_);
}

=method warn

The warn method is used to log a warning event to the event log.

    my  $log  = Scrappy::Logger->new;
    my  %data = ( foo => 'bar');
        $log->warn('Something strange happened today', %data);
    
=cut

sub warn {
    return shift->event('warn', @_);
}

=method error

The error method is used to log an error event to the event log.

    my  $log  = Scrappy::Logger->new;
    my  %data = ( foo => 'bar');
        $log->error('Something strange happened today', %data);
    
=cut

sub error {
    return shift->event('error', @_);
}

=method event

The event method is used to log an event to the event log.

    my  $log  = Scrappy::Logger->new;
    my  %data = ( foo => 'bar');
    my  $type = 'WTF';
        $log->event($type, 'Something strange happened today', %data);
    
=cut

sub event {
    my $self = shift;
    my $type = shift;
    my $note = shift;

    croak("Can't record an event without an event-type and notation")
      unless $type && $note;

    $self->{stash} = {} unless defined $self->{stash};

    $self->{stash}->{$type} = [] unless defined $self->{stash}->{$type};

    my $frame = $type eq 'info' || $type eq 'error' || $type eq 'warn' ? 1 : 0;
    my @trace = caller($frame);
    my $entry = scalar @{$self->{stash}->{$type}};
    my $time  = $self->timestamp;
    my $data  = {};
    $data = {
        '// package'  => $trace[0],
        '// filename' => $trace[1],
        '// line'     => $trace[2]
      }
      if $self->verbose;

    $self->{stash}->{$type}->[$entry] = {
        occurred => $time,
        notation => $note,
        eventlog => "[$time] [$type] $note"
      }
      unless defined $self->{stash}->{$type}->[$entry];

    $self->{stash}->{$type}->[$entry]->{metadata} = $data
      if scalar keys %{$data};

    if (@_) {
        my $stash = @_ > 1 ? {@_} : $_[0];
        if ($stash) {
            if (ref $stash eq 'HASH') {
                for (keys %{$stash}) {
                    $self->{stash}->{$type}->[$entry]->{metadata}->{$_} =
                      $stash->{$_};
                }
            }
        }
    }

    $self->write;
    return $self->{stash}->{$type}->[$entry];
}

=method write

The write method is used to write the specified log file. This happens
automatically is a file is specified using either the load() or write() methods
when events are recorded.

    my  $log = Scrappy::Logger->new;
        $log->write('log.yml');

=cut

sub write {
    my $self = shift;
    my $file = shift || $self->{file};

    $self->{file} = $file;

    if ($file) {

        # write session file
        DumpFile($file, $self->{stash})
          or
          croak("Session file $file does not exist or is not read/writable");
    }

    return $self->{stash};
}

1;
