package Scrappy::Plugin;

# load OO System
use Moose;

# load other libraries
use File::Find::Rule;

# a hash list of installed plugins
has registry => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {

        # map plugins
        my $plugins = {};
        my @plugins = @{shift->plugins};
        foreach my $plugin (@plugins) {
            $plugins->{$plugin} = $plugin;
            $plugins->{lc($plugin)} = $plugin;
        }
        return $plugins;
    }
);

# return a list of installed plugins
has plugins => (
    is      => 'ro',
    isa     => 'Any',
    default => sub {

        my @plugins = ();

        my @files =
          File::Find::Rule->file()->name('*.pm')
          ->in(map {"$_/Scrappy/Plugin"} @INC);

        my %plugins = map { $_ => 1 } @files; #uniquenes

        for my $plugin (keys %plugins) {

            my ($plug) = $plugin =~ /(Scrappy\/Plugin\/.*)\.pm/;

            if ($plug) {
                $plug =~ s/\//::/g;
                push @plugins, $plug;
            }

        }

        return [@plugins];
    }
);

sub load_plugin {
    my $self    = shift;
    my @plugins = @_;
    my @returns = ();

    foreach my $plugin (@plugins) {

        unless ($plugin =~ /^Scrappy::Plugin::/) {

            # make fully-quaified plugin name
            $plugin = ucfirst $plugin;

            $plugin = join("::", map(ucfirst, split '-', $plugin))
              if $plugin =~ /\-/;
            $plugin = join("", map(ucfirst, split '_', $plugin))
              if $plugin =~ /\_/;

            $plugin = "Scrappy::Plugin::$plugin";
        }

        # check for a direct match
        if ($self->registry->{$plugin}) {
            with $self->registry->{$plugin};
            push @returns, $self->registry->{$plugin};
        }

        # last resort seek
        elsif ($self->registry->{lc($plugin)}) {
            with $self->registry->{lc($plugin)};
            push @returns, $self->registry->{lc($plugin)};
        }
        else {
            die(    "Error loading the plugin $plugin, "
                  . "please check that it has been installed");
        }
    }

    return @returns;
}

1;
