#!perl

use strict;
use warnings;

use Test::More tests => 11;
use Data::Document;
use Data::Document::Row;
use Data::Document::Renderer::CSV;

my $csv = Data::Document::Renderer::CSV->new();
isa_ok( $csv, 'Data::Document::Renderer::CSV' );
can_ok( $csv, 'render' );

my $row1 = Data::Document::Row->new('hello');
my $row2 = Data::Document::Row->new('world');
isa_ok( $_, 'Data::Document::Row' ) for $row1, $row2;
my $result = $csv->render( $row1, $row2 );
is( $result, 'helloworld', 'CSV rendering' );

my $doc1 = Data::Document->new(
    rows => {
        $row1->object_id => $row1,
        $row2->object_id => $row2,
    }
);

isa_ok( $doc1, 'Data::Document' );
can_ok( $doc1, 'render' );

is_deeply(
    $result,
    $doc1->render('CSV'),
    'Render directly vs. through Data::Document',
);

my $doc2 = Data::Document->new();
isa_ok( $doc2, 'Data::Document'   );
can_ok( $doc2, qw<add_row render> );
$doc2->add_row('hello');
$doc2->add_row('world');

is_deeply(
    $result,
    $doc2->render('CSV'),
    'Render directly vs. through Data::Document + add_row',
)

