package Scrappy::Project;

use File::Find::Rule;
use Scrappy;
use Moose::Role;

has app => (
    is      => 'ro',
    isa     => 'Any',
    default => sub {
        my  $self = shift;
            $self->scraper(Scrappy->new);
        my  $meta = $self->meta;
        return $meta->has_method('setup') ? $self->setup : $self;
    }
);

has parsers => (
    is      => 'ro',
    isa     => 'Any',
    default => sub {
        my  $self    = shift;
        my  $class   = ref $self;
        my  @parsers = ();

            $class =~ s/::/\//g;

        my  @files =
            File::Find::Rule->file()->name('*.pm')
            ->in( map { "$_/$class" } @INC );
        
        my  %parsers =
            map { $_ => 1 }
                @files; #uniquenes

        for my $parser (keys %parsers) {

            my ($plug) = $parser =~ /($class\/.*)\.pm/;

            if ($plug) {
                $plug =~ s/\//::/g;
                push @parsers, $plug;
            }

        }

        return [@parsers];
    }
);

has registry => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        # map parsers
        my $parsers = {};
        my @parsers = @{ shift->parsers };
        foreach my $parser (@parsers) {
            $parsers->{$parser} = $parser;
            $parsers->{ lc($parser) } = $parser;
        }
        return $parsers;
    }
);

has records => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {{}}
);

has routes => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} }
);

has scraper => (
    is      => 'rw',
    isa     => 'Scrappy'
);

sub route {
    my $self    = shift;
    my $options = {};

    # basic definition
    ( $options->{route}, $options->{parser} ) = @_ if scalar @_ == 2;

    # odd definition
    if ( @_ % 2 ) {
        my $route = shift;
        $options = {@_};
        $options->{route} = $route;
    }

    # check route and parser spec
    die "Error defining route, must have a route and parser assignment"
      unless $options->{route} && $options->{parser};

    # covert parser from shortcut if used
    if ( $options->{parser} !~ ref($self) . "::" ) {

        my $parser = $options->{parser};

        # make fully-quaified parser name
        $parser = ucfirst $parser;
        $parser = join( "::", map( ucfirst, split '-', $parser ) )
          if $parser =~ /\-/;
        $parser = join( "", map( ucfirst, split '_', $parser ) )
          if $parser =~ /\_/;

        $options->{parser} = ref($self) . "::$parser";
    }

    # find action if not specified
    #unless ( defined $options->{action} ) {
    #    my ($action) = $options->{parser} =~ /\#(.*)$/;
    #    $options->{parser} =~ s/\#(.*)$//;
    #    $options->{action} = $action;
    #}

    $self->routes->{ $options->{route} } = $options;
    delete $self->routes->{ $options->{route} }->{route};

    return $self;
}

sub parse_document {
    my ($self, $url) = @_;
    my $scraper = $self->scraper;
    
    die "Can't parse document without a URL"
        unless $url;
    
    # try to match against route(s)
    foreach my $route (keys %{ $self->routes }) {
        my $this = $scraper->page_match($route, $url);
        if ($this) {
            my  $parser = $self->routes->{$route}->{parser};
            #my  $action = $self->routes->{$route}->{action};
            
            no  warnings 'redefine';
            no  strict 'refs';
            my  $module = $parser;
                $module =~ s/::/\//g;
                
            require "$module.pm";
            
            my  $new = $parser->new;
                $new->scraper($scraper);
                
                $self->records->{ref($self)} = []
                    unless defined $self->records->{ref($self)};
                
            my  $record = $new->parse($this);
                push @{$self->records->{ref($self)}}, $record;
                
            return $record;
        }
    }
    return 0;
}

sub spider {
    my  ($class, $starting_url) = @_;
    my  $self  = ref $class ? $class : $class->new;
    
    croak("Error, can't execute the spider without a starting url")
        unless $starting_url;
    
    my  $q = $self->scraper->queue;
        $q->add($starting_url); # starting url
    
    while (my $url = $q->next) {
        
        # parse document data
        $self->scraper->get($url);
        $self->parse_document($url)
            if $self->scraper->page_loaded
            && $self->scraper->page_ishtml
            && $self->scraper->page_status == 200;
        
        foreach my $link (@{ $self->scraper->select('a')->data }) {
            $q->add($link->{href});
        }
    }
}

1;
