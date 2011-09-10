package XML::LibXML::Cache::Base;
use strict;

# ABSTRACT: Base class for XML::LibXML caches

use URI;
use XML::LibXML 1.59;

our $input_callbacks = XML::LibXML::InputCallback->new();
$input_callbacks->register_callbacks([
    \&_match_cb,
    \&_open_cb,
    \&_read_cb,
    \&_close_cb,
]);

my $deps_found;

sub new {
    my $class = shift;

    my $self = { cache => {} };

    return bless($self, $class);
}

sub _cache_lookup {
    my ($self, $filename, $get_item) = @_;

    my $item = $self->_cache_read($filename);

    return $item if $item;

    $deps_found = {};

    $item = $get_item->($filename);

    $self->_cache_write($filename, $item);

    $deps_found = undef;

    return $item;
}

sub _cache_read {
    my ($self, $filename) = @_;

    my $cache_rec = $self->{cache}{$filename}
        or return ();

    my ($item, $deps) = @$cache_rec;

    # check sizes and mtimes of deps_found

    while (my ($path, $attrs) = each(%$deps)) {
        my @stat = stat($path);
        my ($size, $mtime) = @stat ? ($stat[7], $stat[9]) : (-1, -1);

        return () if $size != $attrs->[0] || $mtime != $attrs->[1];
    }

    return $item;
}

sub _cache_write {
    my ($self, $filename, $item) = @_;

    my $cache = $self->{cache};

    if ($deps_found) {
        $cache->{$filename} = [ $item, $deps_found ];
    }
    else {
        delete($cache->{$filename});
    }
}

# Handling of dependencies

# We register an input callback that never matches but records all URIs
# that are accessed during parsing of the stylesheet.

sub _match_cb {
    my $uri_str = shift;

    return undef if !$deps_found;

    my $uri = URI->new($uri_str, 'file');
    my $scheme = $uri->scheme;

    if (!defined($scheme) || $scheme eq 'file') {
        my $path = $uri->path;
        my @stat = stat($path);
        $deps_found->{$path} = @stat ?
            [ $stat[7], $stat[9] ] :
            [ -1, -1 ];
    }
    else {
        # The stylesheet depends on an unsupported URI
        $deps_found = undef;
    }

    return undef;
}

# should never be called
sub _open_cb { die('open callback called unexpectedly'); }
sub _read_cb { die('read callback called unexpectedly'); }
sub _close_cb { die('close callback called unexpectedly'); }

1;

__END__

=head1 DESCRIPTION

Base class for the document and stylesheet caches.

=cut

