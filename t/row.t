#!perl

use strict;
use warnings;

use Test::More tests => 14;
use Test::Fatal;
use Data::Document::Row;
use Data::Document::Item;

is(
    exception { Data::Document::Row->new },
    undef,
    'New without content/items',
);

{
    my $row = Data::Document::Row->new('woohoo');
    isa_ok( $row, 'Data::Document::Row' );
    can_ok( $row, qw<add_item remove_item items_list> );
    my @items = $row->items_list;
    cmp_ok( scalar @items, '==', 1, 'Row items' );
    isa_ok( $items[0], 'Data::Document::Item' );
    is( $items[0]->content, 'woohoo', 'Item content' );

    my $items = $row->items;
    is_deeply(
        $items,
        [ $items[0] ],
        'items vs. items_list',
    );
}

{
    my $item = Data::Document::Item->new(
        'hi', format => 'Mal',
    );
    my $row = Data::Document::Row->new(
        items  => [$item],
        format => 'Gorgak',
    );

    isa_ok( $row, 'Data::Document::Row' );
    my @items = $row->items_list;
    cmp_ok( scalar @items, '==', 1, 'Row items' );
    isa_ok( $items[0], 'Data::Document::Item' );
    is( $items[0]->content, 'hi', 'Item content' );
    is( $items[0]->format, 'Mal', 'Item format' );
    is( $row->format, 'Gorgak', 'Row format' );

    my $items = $row->items;
    is_deeply(
        $items,
        [ $items[0] ],
        'items vs. items_list',
    );
}

