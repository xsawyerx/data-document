package Data::Document::Renderer::CSV;
# ABSTRACT: CSV renderer for Data::Document

use Moo;
use Sub::Quote 'quote_sub';
use MooX::Types::MooseLike::Base qw<ArrayRef>;
use autodie;
use Text::CSV;

with 'Data::Document::Role::Renderer';

has args => (
    is        => 'ro',
    isa       => ArrayRef,
    predicate => 1,
);

has csv => (
    is  => 'lazy',
    isa => quote_sub(q{
        use Safe::Isa;
        $_[0]->$_isa('Text::CSV')
            or die "$_[0] must be a Text::CSV object";
    }),
);

sub _build_csv {
    my $self = shift;
    my $csv  = Text::CSV->new(
        $self->has_args ? @{ $self->argsbinary } : ()
    ) or die 'Cannot create Text::CSV object: ' . Text::CSV->error_diag;

    return $csv;
}

sub render {
    my $self = shift;
    my @rows = @_;
    my $csv  = $self->csv;
    my $out;
    open my $fh, '>', \$out;

    foreach my $row (@rows) {
        my @items = $row->items_list;
        $csv->print( $fh, [ map { $_->content } @items ] )
            or die q{Can't CSV print to scalar};
    }

    close $fh;

    return $out;
}

1;

