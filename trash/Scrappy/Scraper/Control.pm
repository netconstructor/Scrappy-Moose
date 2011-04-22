package Scrappy::Scraper::Control;

# load OO System
use Moose;

has 'allowed'    => (is => 'rw', isa => 'HashRef[Int]', default => sub { {} });
has 'restricted' => (is => 'rw', isa => 'HashRef[Int]', default => sub { {} });

sub allow {
    my ($self, @domains) = @_;
    my $i = 0;
    for (@domains) {
        delete $self->restricted->{$_} if defined $self->restricted->{$_};
        $self->allowed->{$_} = 1;
        $i++ if defined $_;
    }
    return $i;
}

sub restrict {
    my ($self, @domains) = @_;
    my $i = 0;
    for (@domains) {
        delete $self->allowed->{$_} if defined $self->allowed->{$_};
        $self->restricted->{$_} = 1;
        $i++ if defined $_;
    }
    return $i;
}

sub is_allowed {
    my ($self, $domain) = @_;

    # empty domain not allowed
    return 0 unless $domain;

    # is anything explicitly allowed, if so everything is restrcited unless
    # explicitly defined in allowed
    if ('HASH' eq ref $self->allowed) {
        if (keys %{$self->allowed}) {
            return $self->allowed->{$domain} ? 1 : 0;
        }
    }

    # is it explicitly restricted
    if ('HASH' eq ref $self->restricted) {
        if (keys %{$self->restricted}) {
            return 0 if $self->restricted->{$domain};
        }
    }

    # i guess its cool
    return 1;
}

1;
