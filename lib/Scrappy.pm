# ABSTRACT: All Powerful Web Spidering, Scrapering, Crawling Framework

package Scrappy;

# load OO System
use Moose;

# load other libraries
use FindBin;
use File::ShareDir ':ALL';
use File::Slurp;
use Scrappy::Queue;
use Scrappy::Session;
use Try::Tiny;
use URI;
use URI::QueryParam;
use Web::Scraper;
use WWW::Mechanize;

# load WWW::Mechanize object
has mech => (
    is      => 'ro',
    isa     => 'WWW::Mechanize',
    default => sub {
        WWW::Mechanize->new;
    }
);

# load Scrappy::Queue object
has urls => (
    is      => 'ro',
    isa     => 'Scrappy::Queue',
    default => sub {
        Scrappy::Queue->new;
    }
);

# load Scrappy::Session object
has sess => (
    is      => 'ro',
    isa     => 'Scrappy::Session',
    default => sub {
        Scrappy::Session->new;
    }
);

=head1 SYNOPSIS

Scrappy does it all, any way you like. Lets look at a really simple web scraper.

    #!/usr/bin/perl
    use Scrappy;

    my  $scraper = Scrappy->new;
        $scraper->random_user_agent('firefox', 'linux');
        $scraper->allowed_domains('search.cpan.org');
    
        $scraper->crawl('http://search.cpan.org/recent',
            '#cpansearch li a' => sub {
                # print all recent modules from search.cpan.org
                print shift->text(), "\n";
            }
        );

=head1 DESCRIPTION

Scrappy is an easy (and hopefully fun) way of scraping, spidering, and/or
harvesting information from web pages, web services, and more. Scrappy is a
feature rich, flexible, intelligent web automation tool.

Scrappy (pronounced Scrap+Pee) == 'Scraper Happy' or 'Happy Scraper'; If you
like you may call it Scrapy (pronounced Scrape+Pee) although Python has a web
scraping framework by that name and this module is not a port of that one.

=cut

=method allowed_domains

The allowed_domains method gets/sets an optional list of strings containing
domains Scrappy is allowed to access. Requests for URLs not belonging to the
domain names specified in this list will be ignored.

    my  $scraper = Scrappy->new;
        $scraper->allowed_domains('http://google.com', 'http://aol.com');

=cut

sub allowed_domains {
    my $self = shift;
    my @urls = @_;
    
    my $uri = URI->new;
    
    $self->stash('allowed_domains' => [])
        unless defined $self->stash('allowed_domains');
    
    # validate and strip everything but the host part of the URI
    map {
        my $u = URI->new($_);
        $_ = 'URI::_generic' eq ref $u ? $_ : $u->host
    }   @urls;
        
    $self->stash('allowed_domains' => [@urls]) if @urls;
    
    return $self->stash('allowed_domains');
}

=method form

The form method provides a simple interface for submitting form data. 

    $self->form(fields => {
        username => 'mrmagoo',
        password => 'foobarbaz'
    });
    
    # or more specifically
    
    $self->form(form_number => 1, fields => {
        username => 'mrmagoo',
        password => 'foobarbaz'
    });

=cut

sub form {
    my $self = shift;
    my $response = $self->mech->submit_form(@_);
    sleep $self->pause();
    return $response;
}

=method get

The get method takes a URL or URI and returns an HTTP::Response object.

    my  $scraper = Scrappy->new;
        $scraper->get($new_url);

=cut

sub get {
    my $self = shift;
    my $url = URI->new(@_);
    my $request = $self->mech->get($url);
    
    $self->stash->{history} = [] unless defined $self->stash->{history};
    push @{$self->stash->{history}}, @_;
    $self->mech->{cookie_jar}->scan(sub{
        
        my ($version,   $key,    $val,     $path,    $domain, $port,
            $path_spec, $secure, $expires, $discard, $hash) = @_;
        
        $self->session('cookies' => {})
          unless defined $self->session('cookies');
          
        $self->session->stash->{'cookies'}->{$domain}->{$key} = {
            version   => $version,
            key       => $key,
            val       => $val,
            path      => $path,
            domain    => $domain,
            port      => $port,
            path_spec => $path_spec,
            secure    => $secure,
            expires   => $expires,
            discard   => $discard,
            hash      => $hash
        };
        
        $self->session->write if $self->session->{file};
        
    });
    $self->mech->{params} = {};
    $self->mech->{params} = {
        map { ( $_ => $url->query_param($_) ) } $url->query_param
    };
    sleep $self->pause;
    
    return $self;
}

=method pause

The pause method is an adaptation of the WWW::Mechanize::Sleep module. This method
sets breaks between your requests in an attempt to simulate human interaction.

    my  $scraper = Scrappy->new;
        $scraper->pause(20);
    
        $scraper->get($request_1);
        $scraper->get($request_2);
        $scraper->get($request_3);
    
Given the above example, there will be a 20 sencond break between each request made,
get, post, request, etc., You can also specify a range to have the pause method
select from at random...

        $scraper->pause(5,20);
    
        $scraper->get($request_1);
        $scraper->get($request_2);
    
        # reset/turn it off
        $scraper->pause(0);
    
        print "I slept for ", ($scraper->pause), " seconds";
    
Note! The download method is exempt from any automatic pausing.

=cut

sub pause {
    my $self = shift;
    if (defined $_[0]) {
        if ($_[1]) {
            my @range = (($_[0] < $_[1] ? $_[0] : 0)..$_[1]);
            $self->mech->{pause_range} = [$_[0], $_[1]];
            $self->mech->{pause} = $range[rand(@range)];
        }
        else {
            $self->mech->{pause} = $_[0];
            $self->mech->{pause_range} = [0, 0] unless $_[0];
        }
    }
    else {
        my $interval = $self->mech->{pause} || 0;
        
        # select the next random pause value from the range
        if (defined $self->mech->{pause_range}) {
            my @range = @{ $self->mech->{pause_range} };
            $self->pause(@range) if @range == 2;
        }
        
        return $interval;
    }
}

=method queue

The queue method uses L<Scrappy::Queue> to add valid URLs to the page fetching
queue.

    my  $scraper = Scrappy->new;
        $scraper->queue($new_url);
    
    my @urls = $scraper->queue->list;

=cut

sub queue {
    my $self = shift;
    my @urls = @_;
    
    $self->urls->add(@urls) if @urls;
    
    return $self->urls;
}

=method random_user_agent

The random_user_agent method sets the user-agent using a random user-agent string.
The user-agent header in your request is how an inquiring application might determine
the browser and environment making the request. The first argument should be the
name of the web browser, supported web browsers are any, chrome, ie or explorer,
opera, safari, and firfox. Obviously using the keyword 'any' will select from
any available browsers. The second argument which is optional should be the name
of the desired operating system, supported operating systems are windows,
macintosh, and linux. 

    my  $scraper = Scrappy->new;
        $scraper->random_user_agent;
        # same as $scraper->random_user_agent('any');
        
        print $scraper->user_agent;
        
        # ... for a Linux-specific Google Chrome user-agent use the following
        $scraper->random_user_agent('chrome', 'linux');

=cut

sub random_user_agent {
    my $self = shift;
    my ($browser, $os) = @_;
       
       $browser = 'any' unless $browser;
       
       $browser = 'explorer' if
        lc($browser) eq 'internet explorer' ||
        lc($browser) eq 'explorer' ||
        lc($browser) eq 'ie';
       
       $browser = lc $browser;
    
    my @browsers = (
        'explorer',
        'chrome',
        'firefox',
        'opera',
        'safari'
    );
    
    my @oss = (
        'Windows',
        'Linux',
        'Macintosh'
    );
    
    if ($browser ne 'any') {
        croak ("Can't load user-agents from unrecognized browser $browser")
        unless grep /^$browser$/, @browsers;
    }
        
    if ($os) {
        $os = ucfirst(lc($os));
        croak ("Can't filter user-agents with an unrecognized Os $os")
        unless grep /^$os$/, @oss;
    }
    
    my  @selection = ();
        $self->stash->{'user-agents'} = {}
            unless defined $self->stash->{'user-agents'};
    
    if ($browser eq 'any') {
        if ($self->stash->{'user-agents'}->{any}) {
            @selection = @{$self->stash->{'user-agents'}->{any}};
        }
        else {
            foreach my $file (@browsers) {
                my $u = dist_dir('Scrappy') . "/support/$file.txt";
                   $u = "share/support/$file.txt" unless -e $u;
                push @selection, read_file($u);
            }
            $self->stash->{'user-agents'}->{'any'} = [@selection];
        }
    }
    else {
        if ($self->stash->{'user-agents'}->{$browser}) {
            @selection = @{$self->stash->{'user-agents'}->{$browser}};
        }
        else {
            my $u = dist_dir('Scrappy') . "/support/$browser.txt";
               $u = "share/support/$browser.txt" unless -e $u;
            push @selection, read_file($u);
            $self->stash->{'user-agents'}->{$browser} = [@selection];
        }
    }
    
    @selection = grep /$os/, @selection if $os;
    
    return $self->user_agent($selection[rand(@selection)]);
}

=method session

The session method provides a means for storing important data across executions.
Please make sure the session file exists and is writable. As I am sure you've
deduced from the example, the session file will be stored as YAML code. Cookies
are automatically stored in and retrieved from your session file automatically.

    my  $scraper = Scrappy->new;
        
        # use special key to load existing session file and reload saved cookies
        $scraper->session(':file' => 'file.yml');
        $scraper->session(age => 31);

=cut

sub session {
    my $self = shift;
    my @params = @_;
    
    if (defined $params[0]) {
        if (scalar(@params) > 1) {
            if ($params[0] eq ':file') {
                # load specified session file
                if ($self->sess->load($params[1])) {
                    # attempt to reload cookies from previous session
                    if (keys %{$self->sess->stash}) {
                        if (keys %{$self->sess->stash->{'cookies'}}) {
                            if (ref($self->mech->{cookie_jar}) eq "HTTP::Cookies") {
                                foreach my $domain (keys %{$self->sess->stash->{'cookies'}}) {
                                    foreach my $key (keys %{$self->sess->stash->{'cookies'}->{$domain}}) {
                                        $self->mech->{cookie_jar}->set_cookie(
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{version},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{key},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{val},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{path},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{domain},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{port},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{path_spec},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{secure},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{maxage},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{discard},
                                            $self->sess->stash->{'cookies'}->{$domain}->{$key}->{hash}
                                        );
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                $self->sess->stash(@params);
                $self->sess->write;
            }
        }
        else {            
            return $self->sess->stash(@params);
        }
    }
    
    return $self->sess;
}

=method stash

The stash method sets a stash (shared) variable or returns a reference to the entire
stash object.

    my  $scraper = Scrappy->new;
        $scraper->stash(age => 31);
        
    print 'stash access works'
        if $scraper->stash('age') == $scraper->stash->{age};
    
    my @array = (1..20);
    $scraper->stash(integers => [@array]);
    
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

=method user_agent

The user_agent method gets/sets the user-agent used when fetching web pages.
The user-agent header in your request is how an inquiring application might
determine the browser and environment making the request.

    my  $scraper = Scrappy->new;
        $scraper->user_agent('Mozilla/5.0 (Windows; U; Windows NT ...');
        
        print $scraper->user_agent;

=cut

sub user_agent {
    my $self = shift;
    my $user_agent = shift;
    
    $self->mech->agent($user_agent)
        if defined $user_agent;
    
    return $user_agent ? $user_agent : $self->mech->agent;
}

1;