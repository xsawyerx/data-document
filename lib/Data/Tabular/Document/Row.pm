package Data::Tabular::Document::Row;
use Moo;
use Sub::Quote 'quote_sub';
use MooX::Types::MooseLike::Base qw<Str>;
use Safe::Isa;
use Object::ID;
use Data::Tabular::Document::Item;

has format  => ( is => 'ro' );

has items => (
    is  => 'ro',
    isa => quote_sub(q!
        use Safe::Isa;
        ref $_[0] and ref $_[0] eq 'ARRAY'
            or die "$_[0] must be an arrayref";

        my $namespace = 'Data::Tabular::Document::Item';

        foreach my $item ( @{ $_[0] } ) {
            $item->$_isa($namespace)
                or die "$item must be a $namespace object";
        }
    !),
);

has content => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub BUILDARGS {
    my $class = shift;

    @_ % 2 == 0 and return {@_};

    my $content = shift;
    my $args    = {
        items => Data::Tabular::Document::Item->new($content),
        @_,
    };
    return $args;
}

sub add_item {
    my $self    = shift;
    my $content = shift;
    my %args    = @_;

    if ( $content->$_isa('Data::Tabular::Document::Item') ) {
        my $id = $content->object_id;
        $self->{'items'}{$id} = $content;
        return $id;
    }

    my $item = Data::Tabular::Document::Item->new( $content, %args );
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

