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

sub focus {
    my $self = shift;
    my $index = shift || 0;

    $self->is_html;

    $self->html($self->data->[$index]->{html});
    return $self;
}

sub scrape {
    my ($self, $selector) = @_;

    $self->is_html;

    $self->select($selector);
    return $self->data;
}

sub select {
    my ($self, $selector) = @_;

    $self->is_html;

    $self->worker->{code} = scraper {
        process($selector, "data[]", $self->html_tags);
    };

    my $scraper = $self->worker->{code};

    $self->data($scraper->scrape($self->html)->{data} || []);
    return $self;
}

sub is_html {
    my $self = shift;
    croak("Can't parse HTML document without providing a valid source")
      unless $self->html;
}

1;
