package XML::LibXSLT::Cache;

use strict;
use warnings;

# ABSTRACT: Style sheet cache for XML::LibXSLT

use base qw(XML::LibXML::Cache::Base);

sub new {
    my $class   = shift;
    my $options = @_ > 1 ? { @_ } : $_[0];

    my $self = $class->SUPER::new;

    my $xslt = $options->{xslt};
    
    if (!$xslt) {
        require XML::LibXSLT;
        $xslt = XML::LibXSLT->new;
    }

    $self->{xslt} = $xslt;

    $xslt->input_callbacks($XML::LibXML::Cache::Base::input_callbacks);

    return $self;
}

sub parse_stylesheet_file {
    my ($self, $filename) = @_;

    return $self->_cache_lookup($filename, sub {
        my $filename = shift;

        return $self->{xslt}->parse_stylesheet_file($filename);
    });
}

1;

__END__

=head1 DESCRIPTION

XML::LibXSLT::Cache is a cache for L<XML::LibXSLT> style sheets loaded from
files. It is useful to speed up loading of XSLT style sheets in persistent web
applications.

This module caches the style sheet object after the first load and returns the
cached version on subsequent loads. Style sheets are reloaded whenever the
style sheet file changes. Changes to other files referenced during parsing also
cause a reload, for example when using xsl:import and xsl:include.

=head1 SYNOPSIS

    my $cache = XML::LibXSLT::Cache->new;

    my $stylesheet = $cache->parse_stylesheet_file('file.xsl');

=head1 METHODS

=head2 new

    my $cache = XML::LibXSLT::Cache->new(%opts);
    my $cache = XML::LibXSLT::Cache->new(\%opts);

Creates a new cache. Valid options are:

=over

=item xslt

The L<XML::LibXSLT> object that should be used to load stylsheets if you
want to reuse an existing object. If this options is missing a new
XML::LibXSLT object will be created.

=back

=head2 parse_stylesheet_file

    my $stylesheet = $cache->parse_stylesheet_file($filename);

Works like L<XML::LibXSLT/parse_stylesheet_file>.

=cut

