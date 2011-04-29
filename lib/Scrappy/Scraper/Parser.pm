# ABSTRACT: Scrappy Scraper Data Extrator
# Dist::Zilla: +PodWeaver

package Scrappy::Scraper::Parser;

# load OO System
use Moose;

# load other libraries
use Carp;
use Web::Scraper;

# web-scraper object
has 'worker' => (
    is      => 'ro',
    isa     => 'Web::Scraper',
    default => sub {
        scraper(sub { });
    }
);

# html attribute
has html => (is => 'rw', isa => 'Any');

# data attribute
has data => (is => 'rw', isa => 'ArrayRef', default => sub { [] });

# html-tags attribute
has 'html_tags' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {
            'abbr'           => '@abbr',
            'accept-charset' => '@accept',
            'accept'         => '@accept',
            'accesskey'      => '@accesskey',
            'action'         => '@action',
            'align'          => '@align',
            'alink'          => '@alink',
            'alt'            => '@alt',
            'archive'        => '@archive',
            'axis'           => '@axis',
            'background'     => '@background',
            'bgcolor'        => '@bgcolor',
            'border'         => '@border',
            'cellpadding'    => '@cellpadding',
            'cellspacing'    => '@cellspacing',
            'char'           => '@char',
            'charoff'        => '@charoff',
            'charset'        => '@charset',
            'checked'        => '@checked',
            'cite'           => '@cite',
            'class'          => '@class',
            'classid'        => '@classid',
            'clear'          => '@clear',
            'code'           => '@code',
            'codebase'       => '@codebase',
            'codetype'       => '@codetype',
            'color'          => '@color',
            'cols'           => '@cols',
            'colspan'        => '@colspan',
            'compact'        => '@compact',
            'content'        => '@content',
            'coords'         => '@coords',
            'data'           => '@data',
            'datetime'       => '@datetime',
            'declare'        => '@declare',
            'defer'          => '@defer',
            'dir'            => '@dir',
            'disabled'       => '@disabled',
            'enctype'        => '@enctype',
            'face'           => '@face',
            'for'            => '@for',
            'frame'          => '@frame',
            'frameborder'    => '@frameborder',
            'headers'        => '@headers',
            'height'         => '@height',
            'href'           => '@href',
            'hreflang'       => '@hreflang',
            'hspace'         => '@hspace',
            'http'           => '@http-equiv',
            'id'             => '@id',
            'ismap'          => '@ismap',
            'label'          => '@label',
            'lang'           => '@lang',
            'language'       => '@language',
            'link'           => '@link',
            'longdesc'       => '@longdesc',
            'marginheight'   => '@marginheight',
            'marginwidth'    => '@marginwidth',
            'maxlength'      => '@maxlength',
            'media'          => '@media',
            'method'         => '@method',
            'multiple'       => '@multiple',
            'name'           => '@name',
            'nohref'         => '@nohref',
            'noresize'       => '@noresize',
            'noshade'        => '@noshade',
            'nowrap'         => '@nowrap',
            'object'         => '@object',
            'onblur'         => '@onblur',
            'onchange'       => '@onchange',
            'onclick'        => '@onclick',
            'ondblclick'     => '@ondblclick',
            'onfocus'        => '@onfocus',
            'onkeydown'      => '@onkeydown',
            'onkeypress'     => '@onkeypress',
            'onkeyup'        => '@onkeyup',
            'onload'         => '@onload',
            'onmousedown'    => '@onmousedown',
            'onmousemove'    => '@onmousemove',
            'onmouseout'     => '@onmouseout',
            'onmouseover'    => '@onmouseover',
            'onmouseup'      => '@onmouseup',
            'onreset'        => '@onreset',
            'onselect'       => '@onselect',
            'onsubmit'       => '@onsubmit',
            'onunload'       => '@onunload',
            'profile'        => '@profile',
            'prompt'         => '@prompt',
            'readonly'       => '@readonly',
            'rel'            => '@rel',
            'rev'            => '@rev',
            'rows'           => '@rows',
            'rowspan'        => '@rowspan',
            'rules'          => '@rules',
            'scheme'         => '@scheme',
            'scope'          => '@scope',
            'scrolling'      => '@scrolling',
            'selected'       => '@selected',
            'shape'          => '@shape',
            'size'           => '@size',
            'span'           => '@span',
            'src'            => '@src',
            'standby'        => '@standby',
            'start'          => '@start',
            'style'          => '@style',
            'summary'        => '@summary',
            'tabindex'       => '@tabindex',
            'target'         => '@target',
            'text'           => '@text',
            'title'          => '@title',
            'type'           => '@type',
            'usemap'         => '@usemap',
            'valign'         => '@valign',
            'value'          => '@value',
            'valuetype'      => '@valuetype',
            'version'        => '@version',
            'vlink'          => '@vlink',
            'vspace'         => '@vspace',
            'width'          => '@width',
            'text'           => 'TEXT',
            'html'           => 'HTML',
        };
    }
);

=head1 SYNOPSIS

    #!/usr/bin/perl
    use Scrappy::Scraper::Parser;

    my  $parser = Scrappy::Scraper::Parser->new;
        $parser->html($html);
        
        # get all links in all table rows with CSS selector
        my  $links = $parser->scrape('table tr a');
        
        # select all links in the 2nd table row of all tables with XPATH selector
        my  $links = $parser->scrape('//table/tr[2]/a');
        
        # percision scraping !
        # select all links in the 2nd table row ONLY with CSS selectors and focus()
        my  $links = 
            $parser->select('table tr')
               ->focus(2)
               ->scrape('a');
        
=head1 DESCRIPTION

Scrappy::Scraper::Parser provides various tools for scraping/extracting information
from web pages using the L<Scrappy> framework.

=head2 ATTRIBUTES

The following is a list of object attributes available with every Scrappy::Scraper::Parser
instance.

=head3 data

The data attribute gets/sets the extracted data which is returned from the scrape
method.

    my  $parser = Scrappy::Scraper::Parser->new;
        $parser->select('table tr');
        $parser->data;
        
=head3 html

The html attribute gets/sets the HTML content to be parsed and extracted from.

    my  $parser = Scrappy::Scraper::Parser->new;
        $parser->html($HTML);
        
=head3 html_tags

The html_tags attribute gets a hashref of all known HTML tags and attributes to
be used with L<Web::Scraper>.

    my  $parser = Scrappy::Scraper::Parser->new;
        $parser->html_tags;
        
=head3 worker

The worker attribute holds the L<Web::Scraper> object which is used to parse HTML
and extract data.

    my  $parser = Scrappy::Scraper::Parser->new;
        $parser->worker;
        
=method focus

The focus method is used zero-in on specific blocks of HTML so the selectors only
extract data from within the highlighted block. The focus method is meant to be
used after the select method extracts rows of data, the focus method is passed an
array index which zeros-in on that row of data.

    my  $parser = Scrappy::Scraper::Parser->new;
    
    # percision scraping !
    # select all links in the 2nd table row ONLY
    my  $links = 
        $parser->select('table tr')
           ->focus(2)
           ->scrape('a');

=cut

sub focus {
    my $self = shift;
    my $index = shift || 0;

    $self->has_html;

    $self->html($self->data->[$index]->{html});
    return $self;
}

=method scrape

The scrape method is used to extract data from the specified HTML and return the
extracted data. This method is dentical to the select method with the exception of
what is returned.

    my  $parser = Scrappy::Scraper::Parser->new;
    my  $links = $parser->scrape('a', $from_html); #get all links

=cut

sub scrape {
    my ($self, $selector, $html) = @_;

    $self->html($html) if $html;
    $self->has_html;

    $self->select($selector);
    return $self->data;
}

=method select

The select method is used to extract data from the specified HTML and return the
parser object. The data method can be used to access the extracted information.

    my  $parser = Scrappy::Scraper::Parser->new;
        $parser->select('a', $from_html); #get all links
        
    my  $links = $parser->data;

=cut

sub select {
    my ($self, $selector, $html) = @_;

    $self->html($html) if $html;
    $self->has_html;

    $self->worker->{code} = scraper {
        process($selector, "data[]", $self->html_tags);
    };

    my $scraper = $self->worker->{code};

    $self->data($scraper->scrape($self->html)->{data} || []);
    return $self;
}

=method has_html

The has_html method return a boolean which determine whether HTML content has
been set.

    my  $parser = Scrappy::Scraper::Parser->new;
        print 'oh no' unless $parser->has_html;

=cut

sub has_html {
    my $self = shift;
    croak("Can't parse HTML document without providing a valid source")
      unless $self->html;
}

1;
