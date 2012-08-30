#!perl

use strict;
use warnings;

use Test::More tests => 12;
use Test::Fatal;
use Data::Document;

my $doc = Data::Document->new();
isa_ok( $doc, 'Data::Document' );
can_ok( $doc, qw<add_rows remove_rows list_rows> );

my $row1_object = $doc->add_rows(30);
isa_ok( $row1_object, 'Data::Document::Row' );

my @rows = $doc->list_rows;
cmp_ok( scalar @rows, '==', 1, 'Single row stored in document' );

my $row2_object = Data::Document::Row->new(30);
isa_ok( $row2_object, 'Data::Document::Row' );

my $row1_id = $row1_object->object_id;
my $row = $doc->add_rows($row2_object);
my $row2_id = $doc->add_rows($row2_object)->object_id;
@rows = $doc->list_rows;
cmp_ok( scalar @rows, '==', 3, 'Multiple rows stored in document' );
is_deeply(
    \@rows,
    [ $row1_object, $row2_object, $row2_object ],
    'Can get row object',
);

my $rows = $doc->rows;
is_deeply(
    $rows,
    [ $row1_object, $row2_object, $row2_object ],
    'Can dump all rows',
);

$doc->remove_rows($row1_id);
@rows = $doc->list_rows;
cmp_ok( scalar @rows, '==', 2, 'Row successfully deleted' );
is_deeply( \@rows, [ $row2_object, $row2_object ], 'Correct row remained' );
is_deeply(
    $doc->rows,
    [ $row2_object, $row2_object ],
    'Can dump all rows after removal',
);

$doc->remove_rows($row2_id);
@rows = $doc->list_rows;
cmp_ok( scalar @rows, '==', 1, 'Only first row deleted' );

