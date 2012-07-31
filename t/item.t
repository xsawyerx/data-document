use strict;
use warnings;

use Test::More tests => 6;
use Test::Fatal;
use Data::Tabular::Document::Item;

like(
    exception { Data::Tabular::Document::Item->new },
    qr/^\QMissing required arguments: content\E/,
    'New without content fails',
);

{
    my $item = Data::Tabular::Document::Item->new('whoohoo');
    isa_ok( $item, 'Data::Tabular::Document::Item' );
    is( $item->content, 'whoohoo', 'Item content' );
}

{
    my $item = Data::Tabular::Document::Item->new(
        content => 'wheee',
        format  => { kitty => 'kat' },
    );

    isa_ok( $item, 'Data::Tabular::Document::Item' );
    is( $item->content, 'wheee', 'Item content' );
    is_deeply( $item->format, { kitty => 'kat' }, 'Item format' );
}

