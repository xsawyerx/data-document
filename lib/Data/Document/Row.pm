package Data::Document::Row;
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
        ref $items and ref $items eq ref({})
            or die "$items must be a hashref";

        my $namespace = 'Data::Document::Item';

        foreach my $key ( keys %{$items} ) {
            my $object = $items->{$key} || '';
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
        items => {
            $item->object_id => $item,
        },
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
        $self->{'items'}{$id} = $content;
        return $id;
    }

    my $item = Data::Document::Item->new( $content, %args );
    my $id   = $item->object_id;

    $self->{'items'}{$id} = $item;
    return ( $id, $item );
}

sub remove_item {
    my $self = shift;
    my $id   = shift or croak 'Provide an ID to remove';

    delete $self->{'items'}{$id};
}

sub items_list {
    my $self = shift;
    return values %{ $self->items };
}

1;

