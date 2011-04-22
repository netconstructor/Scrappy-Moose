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

sub list {
    return @_queue;
}

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

sub clear {
    my $self = shift;

    @_queue  = ();
    $_cursor = -1;

    return $self;
}

sub reset {
    my $self = shift;

    $_cursor = -1;

    return $self;
}

sub current {
    my $self = shift;

    return $_queue[$_cursor];
}

sub next {
    my $self = shift;

    return $_queue[++$_cursor];
}

sub previous {
    my $self = shift;

    return $_queue[--$_cursor];
}

sub first {
    my $self = shift;
    $_cursor = 0;

    return $_queue[$_cursor];
}

sub last {
    my $self = shift;
    $_cursor = scalar(@_queue) - 1;

    return $_queue[$_cursor];
}

sub index {
    my $self = shift;
    $_cursor = shift || 0;

    return $_queue[$_cursor];
}

sub cursor {
    return $_cursor;
}

1;
