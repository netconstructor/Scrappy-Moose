# ABSTRACT: Scrappy Web Scraper
# Dist::Zilla: +PodWeaver
package Scrappy::Scraper;

# load OO System
use Moose;

# load other libraries
use CGI;
use Scrappy::Queue;
use Scrappy::Logger;
use Scrappy::Scraper::Control;
use Scrappy::Scraper::Parser;
use Scrappy::Scraper::UserAgent;
use Scrappy::Session;
use URI;
use Web::Scraper;
use WWW::Mechanize;

# debug attribute
has 'debug' => (is => 'rw', isa => 'Bool', default => 1);

# html attribute
has 'html' => (is => 'rw', isa => 'Any');

# access control object
has 'control' => (
    is      => 'ro',
    isa     => 'Scrappy::Scraper::Control',
    default => sub {
        Scrappy::Scraper::Control->new;
    }
);

# log object
has 'logger' => (
    is      => 'ro',
    isa     => 'Scrappy::Logger',
    default => sub {
        Scrappy::Logger->new;
    }
);

# parser object
has 'parser' => (
    is      => 'ro',
    isa     => 'Scrappy::Scraper::Parser',
    default => sub {
        Scrappy::Scraper::Parser->new;
    }
);

# queue object
has 'queue' => (
    is      => 'ro',
    isa     => 'Scrappy::Queue',
    default => sub {
        Scrappy::Queue->new;
    }
);

# session object
has 'session' => (
    is      => 'ro',
    isa     => 'Scrappy::Session',
    default => sub {
        Scrappy::Session->new;
    }
);

# user-agent object
has 'user_agent' => (
    is      => 'ro',
    isa     => 'Scrappy::Scraper::UserAgent',
    default => sub {
        Scrappy::Scraper::UserAgent->new;
    }
);

# www-mechanize object (does most of the heavy lifting, gets passed around alot)
has 'worker' => (
    is      => 'ro',
    isa     => 'WWW::Mechanize',
    default => sub {
        WWW::Mechanize->new;
    }
);

=head1 SYNOPSIS

Scrappy::Scraper is the meat and potatoes behind Scrappy.

    #!/usr/bin/perl
    use Scrappy;

    my $scraper = Scrappy->new;
    my $queue = $scraper->queue;
    
    $queue->add('http://search.cpan.org/recent'); # starting url
    
    while (my $url = $queue->next) {
        
        $scraper->get($url);
        
        foreach my $link (@{ $scraper->grab('#cpansearch li a') }) {
            $queue->add($link->href);
        }
    }

=head1 DESCRIPTION

Scrappy is an easy (and hopefully fun) way of scraping, spidering,
and/or harvesting information from web pages, web services, and more. Scrappy is
a feature rich, flexible, intelligent web automation tool.

Scrappy (pronounced Scrap+Pee) == 'Scraper Happy' or 'Happy Scraper';
If you like you may call it Scrapy (pronounced Scrape+Pee) although Python has a
web scraping framework by that name and this module is not a port of that one.

=cut

=method back

The back method is the equivalent of hitting the "back" button in a browser, it
returns the previous page (response), it will not backtrack beyond the first request.

=cut

sub back {
    my $self = shift;

    # specify user-agent
    $self->worker->add_header("User-Agent" => $self->user_agent->name)
      if defined $self->user_agent->name;

    # set html response
    $self->html($self->worker->back);

    $self->log("info", "Navigated back to " . $self->page . " successfully");

    $self->stash->{history} = [] unless defined $self->stash->{history};
    push @{$self->stash->{history}}, $self->page;
    $self->worker->{cookie_jar}->scan(
        sub {

            my ($version, $key,     $val,       $path,
                $domain,  $port,    $path_spec, $secure,
                $expires, $discard, $hash
            ) = @_;

            $self->session->stash('cookies' => {})
              unless defined $self->session->stash('cookies');

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

            $self->session->write;

        }
    );

    return $self;
}

=method cookies

The cookies method is a shortcut to the automatically generated WWW::Mechanize
cookie handler. This method returns an HTTP::Cookie object. Setting this as
undefined using the _undef keyword will prevent cookies from being stored and
subsequently read.

    get $requested_url;
    my $cookies = cookies;
    
    # prevent cookie storage
    cookies _undef;

=cut

sub cookies {
    my $self = shift;
    $self->worker->{cookie_jar} = $_[0] if defined $_[0];
    return $self->worker->{cookie_jar};
}

=method domain

The domain method returns the URI host of the current page.

=cut

sub domain {
    return shift->worker->base;
}

=method download

The download method is passed a URL, a Download Directory Path and a optionally
a File Path, then it will follow the link and store the response contents into
the specified file without leaving the current page. Basically it downloads the
contents of the request (especially when the request pushes a file download). If
a File Path is not specified, Scrappy will attempt to name the file automatically
resorting to a random 6-charater string only if all else fails, then returns to
the originating page.

    my $scaper = Scrappy->new;
    $scraper->download($requested_url, '/tmp');
    
    # supply your own file name
    $scraper->download($requested_url, '/tmp', 'somefile.txt');

=cut

sub download {
    my $self = shift;
    my ($url, $dir, $file) = @_;

    $url = URI->new(@_);

    # access control
    unless ($self->control->is_allowed($url)) {
        $self->log("warn", "$url was not fetched, the url is prohibited");
        return 0;
    }

    # specify user-agent
    $self->worker->add_header("User-Agent" => $self->user_agent->name)
      if defined $self->user_agent->name;

    # set html response
    $dir =~ s/[\\\/]+$//;
    if (@_ == 3) {
        $self->get($url);
        $self->store($dir . '/' . $file);
        $self->log("info",
            "$url was downloaded to " . $dir . '/' . $file . " successfully");
        $self->back;
    }
    elsif (@_ == 2) {
        $self->get($url);
        my @chars = ('a' .. 'z', 'A' .. 'Z', 0 .. 9);
        my $filename = $self->worker->response->filename;
        $filename =
            $chars[rand(@chars)]
          . $chars[rand(@chars)]
          . $chars[rand(@chars)]
          . $chars[rand(@chars)]
          . $chars[rand(@chars)]
          . $chars[rand(@chars)]
          unless $filename;
        $self->store($dir . '/' . $filename);
        $self->log("info",
                "$url was downloaded to " 
              . $dir . '/'
              . $filename
              . " successfully");
        $self->back;
    }
    else {
        croak(
            "To download data from a URI you must supply at least a valid URI "
              . "and download directory path");
    }

    $self->stash->{history} = [] unless defined $self->stash->{history};
    push @{$self->stash->{history}}, $url;

    $self->worker->{params} = {};
    $self->worker->{params} =
      {map { ($_ => $url->query_form($_)) } $url->query_form};

    sleep $self->pause;

    return $self;
}

=method form

The form method is used to submit a form.

    my  $scraper = Scrappy->new;
    
    $scraper->form(fields => {
        username => 'mrmagoo',
        password => 'foobarbaz'
    });
    
    # or more specifically, for pages with multiple forms
    
    $scraper->form(form_number => 1, fields => {
        username => 'mrmagoo',
        password => 'foobarbaz'
    });

=cut

sub form {
    my $self = shift;
    my $url  = $self->page;

    # TODO: need to figure out how to determine the form action before submit

    # access control
    #unless ($self->control->is_allowed($url)) {
    #    $self->log("warn", "$url was not fetched, the url is prohibited");
    #    return 0;
    #}

    # specify user-agent
    $self->worker->add_header("User-Agent" => $self->user_agent->name)
      if defined $self->user_agent->name;

    # set html response
    $self->html($self->worker->submit_form(@_));

    $self->log("info", "form posted from $url successfully", @_);

    #$self->stash->{history} = [] unless defined $self->stash->{history};
    #push @{$self->stash->{history}}, $url;

    $self->worker->{cookie_jar}->scan(
        sub {

            my ($version, $key,     $val,       $path,
                $domain,  $port,    $path_spec, $secure,
                $expires, $discard, $hash
            ) = @_;

            $self->session->stash('cookies' => {})
              unless defined $self->session->stash('cookies');

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

            $self->session->write;

        }
    );

    $self->worker->{params} = {};
    $self->worker->{params} =
      {map { ($_ => $url->query_form($_)) } $url->query_form};

    sleep $self->pause;

    return $self;
}

=method get

The get method takes a URL or URI and returns an HTTP::Response object.

    my  $scraper = Scrappy->new;
        $scraper->get($new_url);

=cut

sub get {
    my $self = shift;
    my $url  = URI->new(@_);

    # access control
    unless ($self->control->is_allowed($url)) {
        $self->log("warn", "$url was not fetched, the url is prohibited");
        return 0;
    }

    # specify user-agent
    $self->worker->add_header("User-Agent" => $self->user_agent->name)
      if defined $self->user_agent->name;

    # set html response
    $self->html($self->worker->get($url));
    $self->log("info", "$url was fetched successfully");

    $self->stash->{history} = [] unless defined $self->stash->{history};
    push @{$self->stash->{history}}, $url;
    $self->worker->{cookie_jar}->scan(
        sub {

            my ($version, $key,     $val,       $path,
                $domain,  $port,    $path_spec, $secure,
                $expires, $discard, $hash
            ) = @_;

            $self->session->stash('cookies' => {})
              unless defined $self->session->stash('cookies');

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

            $self->session->write;

        }
    );

    $self->worker->{params} = {};
    $self->worker->{params} =
      {map { ($_ => $url->query_form($_)) } $url->query_form};

    sleep $self->pause;

    return $self;
}

=method page

The page method returns the URI of the current page.

=cut

sub page {
    return shift->worker->uri;
}

=method page_data

The page_data method returns the content of the current page exactly the same
as the html() function does, additionally this method when passed a string with
HTML markup, updates the content of the current page with that data and returns
the modified content.

=cut

sub page_data {
    my $self = shift;
    if ($_[0]) {
        unless ($_[1]) {
            $self->worker->update_html($_[0]);
        }
    }
    return $self;
}

=method page_loaded

The page_loaded method returns true/false based on whether the last request was
successful.

    my $scraper = Scrappy->new;
    $scraper->get($requested_url);
    
    if ($scraper->page_loaded) {
        ...
    }

=cut

=method page_content_type

The page_content_type method returns the content_type of the current page.

=cut

sub page_content_type {
    return shift->worker->content_type;
}

=method page_ishtml

The page_ishtml method returns true/false based on whether our content is HTML,
according to the HTTP headers.

=cut

sub page_ishtml {
    return shift->worker->is_html;
}

sub page_loaded {
    return shift->worker->success;
}

=method page_match

The page_match method checks the passed-in URL (or URL of the current page if
left empty) against the URL pattern (route) defined. If URL is a match, it will
return the parameters of that match much in the same way a modern web application
framework processes URL routes. 

    my $url = 'http://somesite.com/tags/awesomeness';
    
    ...
    
    my $scraper = Scrappy->new;
    
    # match against the current page
    my $this = $scraper->page_match('/tags/:tag');
    if ($this) {
        print $this->{'tag'};
        # ... prints awesomeness
    }
    
    .. or ..
    
    # match against a passed url
    my $this = $scraper->page_match('/tags/:tag', $url, {
        host => 'somesite.com'
    });
    
    if ($this) {
        print "This is the ", $this->{tag}, " page";
        # ... prints this is the awesomeness page
    }

=cut

sub page_match {
    my $self    = shift;
    my $pattern = shift;
    my $url     = shift || $self->page;
    $url = URI->new($url);
    my $options = shift || {};

    croak("route can't be defined without a valid URL pattern")
      unless $pattern;

    my $route = $self->stash->{patterns}->{$pattern};

    # does route definition already exist?
    unless (keys %{$route}) {

        $route->{on_match} = $options->{on_match};

        # define options
        if (my $host = $options->{host}) {
            $route->{host} = $host;
            $route->{host_re} = ref $host ? $host : qr(^\Q$host\E$);
        }

        $route->{pattern} = $pattern;

        # compile pattern
        my @capture;
        $route->{pattern_re} = do {
            if (ref $pattern) {
                $route->{_regexp_capture} = 1;
                $pattern;
            }
            else {
                $pattern =~ s!
                    \{((?:\{[0-9,]+\}|[^{}]+)+)\} | # /blog/{year:\d{4}}
                    :([A-Za-z0-9_]+)              | # /blog/:year
                    (\*)                          | # /blog/*/*
                    ([^{:*]+)                       # normal string
                !
                    if ($1) {
                        my ($name, $pattern) = split /:/, $1, 2;
                        push @capture, $name;
                        $pattern ? "($pattern)" : "([^/]+)";
                    } elsif ($2) {
                        push @capture, $2;
                        "([^/]+)";
                    } elsif ($3) {
                        push @capture, '__splat__';
                        "(.+)";
                    } else {
                        quotemeta($4);
                    }
                !gex;
                qr{^$pattern$};
            }
        };
        $route->{capture} = \@capture;
        $self->stash->{patterns}->{$route->{pattern}} = $route;
    }

    # match
    if ($route->{host_re}) {
        unless ($url->host =~ $route->{host_re}) {
            return 0;
        }
    }

    if (my @captured = ($url->path =~ $route->{pattern_re})) {
        my %args;
        my @splat;
        if ($route->{_regexp_capture}) {
            push @splat, @captured;
        }
        else {
            for my $i (0 .. @{$route->{capture}} - 1) {
                if ($route->{capture}->[$i] eq '__splat__') {
                    push @splat, $captured[$i];
                }
                else {
                    $args{$route->{capture}->[$i]} = $captured[$i];
                }
            }
        }
        my $match = +{
            (label => $route->{label}),
            %args,
            (@splat ? (splat => \@splat) : ())
        };
        if ($route->{on_match}) {
            my $ret = $route->{on_match}->($self, $match);
            return 0 unless $ret;
        }
        $match->{params} = {%args};
        $match->{params}->{splat} = \@splat if @splat;
        return $match;
    }

    return 0;
}

=method page_reload

The page_reload method acts like the refresh button in a browser, it simply
repeats the current request.

=cut

sub page_reload {
    my $self = shift;

    # specify user-agent
    $self->worker->add_header("User-Agent" => $self->user_agent->name)
      if defined $self->user_agent->name;

    # set html response
    $self->html($self->worker->reload);

    $self->log("info", "page reload successful");

    my $url = $self->page;

    $self->stash->{history} = [] unless defined $self->stash->{history};
    push @{$self->stash->{history}}, $url;
    $self->worker->{cookie_jar}->scan(
        sub {

            my ($version, $key,     $val,       $path,
                $domain,  $port,    $path_spec, $secure,
                $expires, $discard, $hash
            ) = @_;

            $self->session->stash('cookies' => {})
              unless defined $self->session->stash('cookies');

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

            $self->session->write;

        }
    );

    return $self;
}

=method page_status

The page_status method returns the 3-digit HTTP status code of the response.

    my $scraper = Scrappy->new;
    $scraper->get($requested_url);
    
    if ($scraper->page_status == 200) {
        ...
    }

=cut

sub page_status {
    return shift->worker->status;
}

=method page_text

The page_text method returns a text representation of the last page having
all HTML markup stripped.

=cut

sub page_text {
    return shift->page_data(format => 'text');
}

=method page_title

The page_title method returns the content of the title tag if the current page
is HTML, otherwise returns undef.

=cut

sub page_title {
    return shift->worker->title;
}

=method post

The post method takes a URL, a hashref of key/value pairs, and optionally an
array of key/value pairs, and posts that data to the specified URL, then returns
an HTTP::Response object.

    my $scraper = Scrappy->new;

    $scraper->post($requested_url, {
        input_a => 'value_a',
        input_b => 'value_b'
    });
    
    # w/additional headers
    my %headers = ('Content-Type' => 'multipart/form-data');
    $scraper->post($requested_url, {
        input_a => 'value_a',
        input_b => 'value_b'
    },  %headers);

Note! The most common post headers for content-type are
application/x-www-form-urlencoded and multipart/form-data.

=cut

sub post {
    my $self = shift;
    my $url  = $_[0];

    # access control
    unless ($self->control->is_allowed($url)) {
        $self->log("warn", "$url was not fetched, the url is prohibited");
        return 0;
    }

    # specify user-agent
    $self->worker->add_header("User-Agent" => $self->user_agent->name)
      if defined $self->user_agent->name;

    # set html response
    $self->html($self->worker->post(@_));

    $self->log("info", "posted data to $_[0] successfully", @_);

    $self->stash->{history} = [] unless defined $self->stash->{history};
    push @{$self->stash->{history}}, $url;
    $self->worker->{cookie_jar}->scan(
        sub {

            my ($version, $key,     $val,       $path,
                $domain,  $port,    $path_spec, $secure,
                $expires, $discard, $hash
            ) = @_;

            $self->session->stash('cookies' => {})
              unless defined $self->session->stash('cookies');

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

            $self->session->write;

        }
    );

    $self->worker->{params} = {};
    $self->worker->{params} =
      {map { ($_ => $url->query_form($_)) } $url->query_form};

    sleep $self->pause;

    return $self;
}

=method proxy

The proxy method is a shortcut to the WWW::Mechanize proxy function. This method
set the proxy for the next request to be tunneled through. Setting this as
undefined using the _undef keyword will reset the scraper application instance
so that all subsequent requests will not use a proxy.

    my $scraper = Scrappy->new;
    
    $scraper->proxy('http', 'http://proxy.example.com:8000/');
    $scraper->get($requested_url);
    
    $scraper->proxy('http', 'ftp', 'http://proxy.example.com:8000/');
    $scraper->get($requested_url);
    
    # best practice when using proxies
    
    use Tiny::Try;
    
    $scraper->proxy('http', 'http://proxy.example.com:8000/');
    
    try {
        $scraper->get($requested_url);
    };
    
Note! When using a proxy to perform requests, be aware that if they fail your
program will die unless you wrap your code in an eval statement or use a try/catch
mechanism. In the example above we use Tiny::Try to trap any errors that might occur
when using proxy.

=cut

sub proxy {
    my $self     = shift;
    my $proxy    = pop @_;
    my @protocol = @_;
    $self->worker->proxy([@protocol], $proxy);
    $self->log("info", "Set proxy $proxy using protocol(s) " . join ' and ',
        @protocol);
    return $self;
}

=method request_denied

The request_denied method is a simple shortcut to determine if the page you
requested got loaded or redirected. This method is very useful on systems
that require authentication and redirect if not authorized. This function
return boolean, 1 if the current page doesn't match the requested page.

    my $scraper = Scrappy->new;
    $scraper->get($url_to_dashboard);
    
    if ($scraper->request_denied) {
        # do login, again
    }
    else {
        # resume ...
    }

=cut

sub request_denied {
    my $self = shift;
    my ($last) = reverse @{$self->stash->{history}};
    return 1 if ($self->page ne $last);
}

=head2 select

The select method takes XPATH or CSS selectors and returns an arrayref
with the matching elements.

    my $scraper = Scrappy->new;
    
    # return a list of links
    my $list = $scraper->select('#profile li a')->data; # see Scrappy::Scraper::Parser
    
    foreach my $link (@{$list}) {
        print $link->{href}, "\n";
    }
    
    # Zoom in on specific chunks of html code using the following ...
    my $list = $scraper
    ->select('#container table tr') # select all rows
    ->focus(4) # focus on the 5th row
    ->select('div div')->data;
    
    # The code above selects the div > div inside of the 5th tr in #container table
    # Access tag html, text and other attributes as follows...
    
    $element = $scraper->select('table')->data->[0];
    $element->{html}; # HTML representation of the table
    $element->{text}; # Table stripped of all HTML
    $element->{cellpadding}; # cellpadding
    $element->{height}; # ...
    
=cut

sub select {
    my ($self, $selector) = @_;
    my $parser = Scrappy::Scraper::Parser->new;
    $parser->html($self->html);
    return $parser->select($selector);
}

=method log

The log method logs an event with the event logger.

    my  $scraper = Scrappy->new;
        $scraper->debug(1);
        
        $scraper->log('error', 'Somthing bad happened');
        
        ...
        
        $scraper->log('info', 'Somthing happened');
        $scraper->log('warn', 'Somthing strange happened');
        $scraper->log('coolness', 'Somthing cool happened');

=cut

sub log {
    my $self = shift;
    my $type = shift;
    my @args = @_;

    if ($self->debug) {
        if ($type eq 'info') {
            $self->logger->info(@args);
        }
        elsif ($type eq 'warn') {
            $self->logger->warn(@args);
        }
        elsif ($type eq 'error') {
            $self->logger->error(@args);
        }
        else {
            warn $type;
            $self->logger->event($type, @args);
        }

        return 1;
    }
    else {
        return 0;
    }
}

=method pause

This method sets breaks between your requests in an attempt to simulate human
interaction. 

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
            my @range = (($_[0] < $_[1] ? $_[0] : 0) .. $_[1]);
            $self->worker->{pause_range} = [$_[0], $_[1]];
            $self->worker->{pause} = $range[rand(@range)];
        }
        else {
            $self->worker->{pause} = $_[0];
            $self->worker->{pause_range} = [0, 0] unless $_[0];
        }
    }
    else {
        my $interval = $self->worker->{pause} || 0;

        # select the next random pause value from the range
        if (defined $self->worker->{pause_range}) {
            my @range = @{$self->worker->{pause_range}};
            $self->pause(@range) if @range == 2;
        }

        $self->log("info", "processing was halted for $interval seconds")
          if $interval > 0;
        return $interval;
    }
}

=method response

The response method returns the HTTP::Repsonse object of the current page.

=cut

sub response {
    return shift->worker->response;
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
    my $self = shift;
    $self->{stash} = {} unless defined $self->{stash};

    if (@_) {
        my $stash = @_ > 1 ? {@_} : $_[0];
        if ($stash) {
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

=method store

The store method stores the contents of the current page into the specified file.
If the content-type does not begin with 'text', the content is saved as binary data.

    my  $scraper = Scrappy->new;
    
    $scraper->get($requested_url);
    $scraper->store('/tmp/foo.html');

=cut

sub store {
    return shift->worker->save_content(@_);
}

1;
