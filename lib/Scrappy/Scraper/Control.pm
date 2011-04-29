# ABSTRACT: Scrappy HTTP Request Constraints System
# Dist::Zilla: +PodWeaver

package Scrappy::Scraper::Control;

# load OO System
use Moose;

# load other libraries
use URI;

has 'allowed'    => (is => 'rw', isa => 'HashRef', default => sub { {} });
has 'options'    => (is => 'ro', isa => 'HashRef',
    'default'    => sub { { methods => [qw/GET PUT PUSH DELETE POST/] } });
has 'restricted' => (is => 'rw', isa => 'HashRef', default => sub { {} });

=head1 SYNOPSIS

    #!/usr/bin/perl
    use Scrappy::Scraper::Control;

    my  $control = Scrappy::Scraper::Control->new;
    
        $control->allow('http://search.cpan.org/');
        $control->restrict('http://www.cpan.org/');
        
        if ($control->is_allowed('http://search.cpan.org/')) {
            ...
        }
        
=head1 DESCRIPTION

Scrappy::Scraper::Control provides HTTP request access control for the L<Scrappy> framework.

=head2 ATTRIBUTES

The following is a list of object attributes available with every Scrappy::Scraper::Control
instance.

=head3 allowed

The allowed attribute holds a hasherf of allowed domain/contraints.

    my  $control = Scrappy::Scraper::Control->new;
        $control->allowed;
        
        e.g.
        
        {
            'www.foobar.com' => {
                methods => [qw/GET POST PUSH PUT DELETE/]
            }
        }
        
=head3 restricted

The restricted attribute holds a hasherf of restricted domain/contraints.

    my  $control = Scrappy::Scraper::Control->new;
        $control->restricted;
        
        e.g.
        
        {
            'www.foobar.com' => {
                methods => [qw/GET POST PUSH PUT DELETE/]
            }
        }

=method allow

    my  $control = Scrappy::Scraper::Control->new;
        $control->allow('http://search.cpan.org/');
        $control->allow('www.perl.org');

=cut

sub allow {
    my  ($self, @domains) = @_;
    my  $i = 0;
    
    for (@domains) {
        
        $_ = URI->new($_)->host if $_ =~ /\:\/\//; # url to domain
        
        next unless $_;
        delete $self->restricted->{$_} if defined $self->restricted->{$_};
        $self->allowed->{$_} = $self->options;
        $i++ if defined $_;
    }
    return $i;
}

=method restrict

    my  $control = Scrappy::Scraper::Control->new;
        $control->restrict('http://search.cpan.org/');
        $control->restrict('www.perl.org');

=cut

sub restrict {
    my  ($self, @domains) = @_;
    my  $i = 0;
    for (@domains) {
        
        $_ = URI->new($_)->host if $_ =~ /\:\/\//; # url to domain
        
        next unless $_;
        delete $self->allowed->{$_} if defined $self->allowed->{$_};
        $self->restricted->{$_} = $self->options;
        $i++ if defined $_;
    }
    return $i;
}

=method is_allowed

    my  $control = Scrappy::Scraper::Control->new;
        $control->allow('http://search.cpan.org/');
        $control->restrict('www.perl.org');
        
        if (! $control->is_allowed('perl.org')) {
            die 'Cant get to Perl.org';
        }

=cut

sub is_allowed {
    my  $self = shift;
    my  $url = shift;
        $url = URI->new($url)->host if $url =~ /\:\/\//; # url to domain
    my  %options = @_;

    # empty domain not allowed
    return 0 unless $url;

    # is anything explicitly allowed, if so everything is restricted unless
    # explicitly defined in allowed
    if (keys %{$self->allowed}) {
        if (keys %{$self->allowed}) {
            return $self->allowed->{$url} ? 1 : 0;
        }
    }

    # is it explicitly restricted
    if (keys %{$self->restricted}) {
        if (keys %{$self->restricted}) {
            return 0 if $self->restricted->{$url};
        }
    }

    # i guess its cool
    return 1;
}

1;
