package Data::Document::Row;
# ABSTRACT: A document row object

use Moo;
use Sub::Quote 'quote_sub';
use MooX::Types::MooseLike::Base qw<Str>;
use Carp;
use Safe::Isa;
use Object::ID;
use Data::Document::Item;

with 'Data::Document::Role::Formattable';

has items => (
    is  => 'ro',
    isa => quote_sub(q!
        use Safe::Isa;
        my $items = shift;
        ref $items and ref $items eq ref([])
            or die "$items must be a arrayref";

        my $namespace = 'Data::Document::Item';

        foreach my $object ( @{$items} ) {
            $object->$_isa($namespace)
                or die "$object must be a $namespace object";
        }
    !),
);

sub BUILDARGS {
    my $class = shift;

    @_ % 2 == 0 and return {@_};

    my $content = shift;
    my $item    = Data::Document::Item->new($content);
    my $args    = {
        items => [$item],
        @_,
    };

    return $args;
}

sub add_item {
    my $self    = shift;
    my $content = shift;
    my %args    = @_;

    if ( $content->$_isa('Data::Document::Item') ) {
        my $id = $content->object_id;
        push @{ $self->{'items'} }, $content;
        return $id;
    }

    my $item = Data::Document::Item->new( $content, %args );
    push @{ $self->{'items'} }, $item;
    return $item;
}

sub remove_item {
    my $self = shift;
    my $id   = shift or croak 'Provide an ID to remove';
    my $idx  = 0;

    foreach my $item ( @{ $self->{'items'} } ) {
        if ( $item->object_id eq $id ) {
            splice @{ $self->{'items'} }, $idx, 1;
            last;
        }

        $idx++;
    }
}

sub items_list {
    my $self = shift;
    return $self->items ? @{ $self->items } : ();
}

1;

