package Data::Tabular::Document;
# ABSTRACT: Tabular document thingamagig

use Moo;
use MooX::Types::MooseLike::Base qw<Int Str ArrayRef>;
use Safe::Isa;
use Carp;
use Class::Load 'try_load_class';
use Scalar::Util 'looks_like_number';

use Data::Tabular::Document::Row;

has rows => (
    is  => 'ro',
    isa => ArrayRef,
);

sub add_row {
    my $self    = shift;
    my $content = shift;
    my %args    = @_;

    if ( $content->$_isa('Data::Tabular::Document::Row') ) {
        my $id = $content->object_id;
        $self->{'rows'}{$id} = $content;
        return $id;
    }

    my $row = Data::Tabular::Document::Row->new( $content, %args );
    my $id  = $row->object_id;

    $self->{'rows'}{$id} = $row;
    return ( $id, $row );
}

sub remove_row {
    my $self = shift;
    my $id   = shift or croak 'Provide an ID to remove';

    delete $self->{'rows'}{$id};
}

sub rows_list {
    my $self = shift;
    return values %{ $self->rows };
}

sub render {
    my $self     = shift;
    my $renderer = shift or croak 'Please provide a supported renderer';
    my %args     = @_ ? @_ : ();
    my $class    = "Data::Tabular::Document::Renderer::$renderer";

    my ( $loaded, $res ) = try_load_class($class);
    $loaded or croak "Can't load $class, is it a supported renderer? ($res)";

    $class->new(%args)->render($self);
}

1;

__END__

=head1 SYNOPSIS

FIXME completely outdated example:

    my $doc = Document->new();
    my $row = $doc->add_row(
        30,
        format => $fmt,
    );

    my $item_id = $row->add_item(
        $content,
        column => 10,
        format => $fmt,
    );

    $row->remove_item($item_id);

    my $possible_row = Row->new(
        40,
        format => $fmt,    
    );

    if ($condition) {
        $row->add_row($possible_row);
    }

    $doc->render(
        output_format   => 'Excel',
        output_filename => 'output.xls',
    );

