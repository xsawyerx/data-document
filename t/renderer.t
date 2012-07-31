#!perl

use strict;
use warnings;

use Test::More tests => 9;
use Test::Fatal;
use Data::Document;

my $doc = Data::Document->new();
isa_ok( $doc, 'Data::Document' );
can_ok( $doc, 'render'         );

like(
    exception { $doc->render },
    qr/^Please provide a supported renderer/,
    'Must render with a format',
);

like(
    exception { $doc->render('blah') },
    qr/^Can't load Data::Document::Renderer::blah/,
    'Must render with a supported format',
);

{
    package Data::Document::Renderer::Exceptional;
    use Moo;
    use Test::More;
    with 'Data::Document::Role::Renderer';
    my $count = 0;

    has title => (
        is => 'ro',
    );

    sub render {
        my $self = shift;
        my %args = @_;

        isa_ok( $self, 'Data::Document::Renderer::Exceptional' );

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

