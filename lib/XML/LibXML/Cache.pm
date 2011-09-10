package XML::LibXML::Cache;
use strict;

# ABSTRACT: Document cache for XML::LibXML

use base qw(XML::LibXML::Cache::Base);

use XML::LibXML 1.59;

sub new {
    my $class   = shift;
    my $options = @_ > 1 ? { @_ } : $_[0];

    my $self = $class->SUPER::new;

    my $parser = $options->{parser} || XML::LibXML->new();
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
    my ($self, $filename, @opts) = @_;

    return $self->_cache_lookup($filename, sub {
        my $filename = shift;

        return $self->{parser}->parse_html_file($filename, @opts);
    });
}

1;

__END__

=head1 DESCRIPTION

=head1 SYNOPSIS

=cut

