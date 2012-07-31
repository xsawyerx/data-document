package Data::Tabular::Document::Row;
use Moo;
use MooX::Types::MooseLike::Base qw<Str>;
use Object::ID;

has format  => ( is => 'ro' );

has content => (
    is     => 'ro',
    isa    => Str,
    writer => 'set_content',
);

sub BUILDARGS {
    my $class   = shift;
    my $content = shift;
    my $args    = { content => $content, @_ };
    return $args;
}

1;

