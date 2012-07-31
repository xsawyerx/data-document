package Data::Tabular::Document::Item;
use Moo;
use MooX::Types::MooseLike::Base qw<Str>;
use Object::ID;

with 'Data::Tabular::Document::Role::Formattable';

has content => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub BUILDARGS {
    my $class = shift;

    @_ % 2 == 0 and return {@_};

    my $content = shift;
    my $args    = { content => $content, @_ };
    return $args;
}

1;

