#!perl

use strict;
use warnings;

use Data::Tabular::Document;
use Test::More tests => 20;
use Test::Fatal;

my $doc = Data::Tabular::Document->new();

isa_ok( $doc, 'Data::Tabular::Document' );
can_ok( $doc, qw<add_row remove_row rows_list render> );

like(
    exception { $doc->render },
    qr/^Please provide a supported renderer/,
    'Must render with a format',
);

like(
    exception { $doc->render('blah') },
    qr/^Can't load Data::Tabular::Document::Renderer::blah/,
    'Must render with a supported format',
);

{
    package Data::Tabular::Document::Renderer::Exceptional;
    use Moo;
    use Test::More;
    with 'Data::Tabular::Document::Role::Renderer';
    my $count = 0;

    has title => (
        is => 'ro',
    );

    sub render {
        my $self = shift;
        my $doc  = shift;
        my %args = @_;

        isa_ok( $self, 'Data::Tabular::Document::Renderer::Exceptional' );
        isa_ok( $doc,  'Data::Tabular::Document' );

        $count++ == 1 and is( $self->title, 'HI!', 'Renderer arguments set' );
    }
}

is(
    exception { $doc->render('Exceptional') },
    undef,
    'Can render with supported format',
);

is(
    exception { $doc->render( 'Exceptional', title => 'HI!' ) },
    undef,
    'Can render with supported format and args',
);

my ( $row1_id, $row1_object ) = $doc->add_row(30);
isa_ok( $row1_object, 'Data::Tabular::Document::Row' );

my @rows = $doc->rows_list;
cmp_ok( scalar @rows, '==', 1, 'Single row stored in document' );

my $row2_object = Data::Tabular::Document::Row->new(30);
isa_ok( $row2_object, 'Data::Tabular::Document::Row' );

my $row2_id = $doc->add_row($row2_object);
@rows = $doc->rows_list;
cmp_ok( scalar @rows, '==', 2, 'Multiple rows stored in document' );
is_deeply( \@rows, [ $row1_object, $row2_object ], 'Can get row object' );

my %rows = %{ $doc->rows };
is_deeply(
    \%rows,
    {
        $row1_id => $row1_object,
        $row2_id => $row2_object,
    },
    'Can dump all rows',
);

$doc->remove_row($row1_id);
@rows = $doc->rows_list;
cmp_ok( scalar @rows, '==', 1, 'Row successfully deleted' );
is_deeply( \@rows, [$row2_object], 'Correct row remained' );
is_deeply(
    $doc->rows,
    { $row2_id => $row2_object },
    'Can dump all rows after removal',
);

