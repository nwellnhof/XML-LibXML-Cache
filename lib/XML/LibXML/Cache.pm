package XML::LibXML::Cache;

use strict;
use warnings;

# ABSTRACT: Document cache for XML::LibXML

use base qw(XML::LibXML::Cache::Base);

use XML::LibXML 1.59;

sub new {
    my $class   = shift;
    my $options = @_ > 1 ? { @_ } : $_[0];

    my $self = $class->SUPER::new;

    my $parser = $options->{parser} || XML::LibXML->new;
    $self->{parser} = $parser;

    $parser->input_callbacks($XML::LibXML::Cache::Base::input_callbacks);

    return $self;
}

sub parse_file {
    my ($self, $filename) = @_;

    return $self->_cache_lookup($filename, sub {
        my $filename = shift;

        return $self->{parser}->parse_file($filename);
    });
}

sub parse_html_file {
    my ($self, $filename, @args) = @_;

    return $self->_cache_lookup($filename, sub {
        my $filename = shift;

        return $self->{parser}->parse_html_file($filename, @args);
    });
}

1;

__END__

=head1 DESCRIPTION

XML::LibXML::Cache is a cache for L<XML::LibXML> documents loaded from
files. It is useful to speed up loading of XML files in persistent web
applications.

This module caches the document object after the first load and returns the
cached version on subsequent loads. Documents are reloaded whenever the
document file changes. Changes to other files referenced during parsing also
cause a reload. This includes external DTDs, external entities or XIncludes.

=head1 SYNOPSIS

    my $cache = XML::LibXML::Cache->new;

    my $doc = $cache->parse_file('file.xml');
    my $doc = $cache->parse_html_file('file.html', \%opts);

=head1 METHODS

=head2 new

    my $cache = XML::LibXML::Cache->new(%opts);
    my $cache = XML::LibXML::Cache->new(\%opts);

Creates a new cache. Valid options are:

=over

=item parser

The L<XML::LibXML> parser object that should be used to load documents if you
want to use certain parser options. If this option is missing a parser
with default options will be used.

=back

=head2 parse_file

    my $doc = $cache->parse_file($filename);

Works like L<XML::LibXML::Parser/parse_file>.

=head2 parse_html_file

    my $doc = $cache->parse_html_file($filename, \%opts);

Works like L<XML::LibXML::Parser/parse_html_file>.

=cut
