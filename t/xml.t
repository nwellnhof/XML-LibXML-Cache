#!perl -w
use strict;

use File::Touch;
use Test::More tests => 7;
use Test::Deep;

$ENV{XML_CATALOG_FILES} = '';

use_ok('XML::LibXML::Cache');

my $parser = XML::LibXML->new(expand_xinclude => 1);
my $cache = new_ok('XML::LibXML::Cache' => [ parser => $parser ]);
my $filename = 't/xml/test01.xml';
my $entity_filename = 't/xml/test01-entity.xml';
my $time = time;

my $ref = File::Touch->new(mtime => $time - 3600, no_create => 1);
$ref->touch($entity_filename);

my $doc = $cache->parse_file($filename);

my $cached_rec = $cache->{cache}{$filename};
isa_ok($cached_rec, 'ARRAY');

my ($cached_doc, $deps) = @$cached_rec;
is($cached_doc, $doc, 'cached doc');

my $number = re(qr/^\d+\z/);
my $attrs = [ $number, $number ];
cmp_deeply($deps, {
    $filename                  => $attrs,
    $entity_filename           => $attrs,
    't/xml/test01.dtd'         => $attrs,
    't/xml/test01-include.xml' => $attrs,
    't/xml/test01-missing.xml' => [ -1, -1 ],
}, 'dependencies');

$cached_doc = $cache->parse_file($filename);
is(int($cached_doc), int($doc), 'cached doc');

$ref = File::Touch->new(mtime => $time, no_create => 1);
$ref->touch($entity_filename);

my $new_doc = $cache->parse_file($filename);
isnt(int($new_doc), int($doc), 'new doc');

