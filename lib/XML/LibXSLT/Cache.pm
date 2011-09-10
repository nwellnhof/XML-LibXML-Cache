package XML::LibXSLT::Cache;
use strict;

# ABSTRACT: Stylesheet cache for XML::LibXSLT

use base qw(XML::LibXML::Cache::Base);

use XML::LibXML 1.59;

sub new {
    my $class   = shift;
    my $options = @_ > 1 ? { @_ } : $_[0];

    my $self = $class->SUPER::new;

    my $xslt = $options->{xslt};
    
    if (!$xslt) {
        require XML::LibXSLT;
        $xslt = XML::LibXSLT->new();
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

=head1 SYNOPSIS

=cut

