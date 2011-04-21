# ABSTRACT: Scrappy Request Scheduler and Queue System
# Dist::Zilla: +PodWeaver
package Scrappy::Queue;

# load OO System
use Moose;

# load other libraries
use Array::Unique;
use URI;

# queue and cursor variables for navigation
our @_queue = ();
tie @_queue, 'Array::Unique';
our $_cursor = -1;

=head1 SYNOPSIS

    #!/usr/bin/perl
    use Scrappy;

    my  $surl = ... # starting url
    my  $scraper = Scrappy->new;
        
        while (my $url = $scraper->queue($surl)->next) {
            if ($scraper->get($url)) {
                ...
            }
        }

=head1 DESCRIPTION

Scrappy::Queue provides Scrappy with methods for navigating a list of stored URLs.

=cut

=method list

The list method is used to return the ordered list queued URLs.

    my  $queue = Scrappy::Queue->new;
    my  @urls = $queue->list;

=cut

sub list {
    return @_queue;
}

=method add

The add method is used to add URLs to the queue.

    my  $queue = Scrappy::Queue->new;
        $queue->add('http://search.cpan.org', 'http://google.com');

=cut

sub add {
    my $self = shift;
    my @urls = @_;

    # validate and formulate proper URLs
    for (my $i = 0; $i < @urls; $i++) {
        my $u = URI->new($urls[$i]);
        if ('URI::_generic' ne ref $u) {
            $urls[$i] = $u->as_string;
        }
        else {
            unless ($urls[$i] =~ /\w{2,}\.\w{2,}/) {
                delete $urls[$i];
            }
        }
    }

    push @_queue, @urls;
    return $self;
}

=method clear

The clear method empties the URLs queue and resets the queue cursor.

    my  $queue = Scrappy::Queue->new;
        $queue->clear;

=cut

sub clear {
    my $self = shift;

    @_queue  = ();
    $_cursor = -1;

    return $self;
}

=method reset

The reset method resets the queue cursor only.

    my  $queue = Scrappy::Queue->new;
        $queue->add(...);
    my  $url = $queue->next;
        $queue->reset;

=cut

sub reset {
    my $self = shift;

    $_cursor = -1;

    return $self;
}

=method current

The current method returns the value of the current position in the queue.

    my  $queue = Scrappy::Queue->new;
        print $queue->current;

=cut

sub current {
    my $self = shift;

    return $_queue[$_cursor];
}

=method next

The next method returns the next value from the current position of the queue.

    my  $queue = Scrappy::Queue->new;
        print $queue->next;

=cut

sub next {
    my $self = shift;

    return $_queue[++$_cursor];
}

=method previous

The previous method returns the previous value from the current position in the queue.

    my  $queue = Scrappy::Queue->new;
        print $queue->previous;

=cut

sub previous {
    my $self = shift;

    return $_queue[--$_cursor];
}

=method first

The first method returns the first value in the queue.

    my  $queue = Scrappy::Queue->new;
        print $queue->first;

=cut

sub first {
    my $self = shift;
    $_cursor = 0;

    return $_queue[$_cursor];
}

=method last

The last method returns the last value in the queue.

    my  $queue = Scrappy::Queue->new;
        print $queue->last;

=cut

sub last {
    my $self = shift;
    $_cursor = scalar(@_queue) - 1;

    return $_queue[$_cursor];
}

=method index

The index method returns the value of the specified position in the queue.

    my  $queue = Scrappy::Queue->new;
    my  $index = 0; # first position (same as array)
        print $queue->index($index);

=cut

sub index {
    my $self = shift;
    $_cursor = shift || 0;

    return $_queue[$_cursor];
}

=method cursor

The cursor method returns the value (index position) of the cursor.

    my  $queue = Scrappy::Queue->new;
        print $queue->cursor;

=cut

sub cursor {
    return $_cursor;
}

1;
