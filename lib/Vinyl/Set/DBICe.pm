package Vinyl::Set::DBICe;
use Moose;
use MooseX::Types::DBIx::Class qw/ResultSet/;

has 'class_name' => is=>'ro';
has 'rs'     => is => 'rw',
    isa      => ResultSet,
    required => 1,
    handles  => [ qw/all find first reset next search delete count/ ];

around [qw/all first next/] => sub {
    my ($orig, $self) = (shift,shift);
    my @result = map { bless { $_->get_columns } => $self->class_name }
        $self->$orig( @_ ) ;
    @result > 1 ? @result : $result[0];
};

with 'Vinyl::Role::Set';

no Moose;

sub last {  ... }

sub all_new {
    my $self = shift;
    my $class = $self->class_name;
    map { $class->new( $_->get_columns ) } $self->rs->all;
};

sub first_new {
    my $self = shift;
    my $class = $self->class_name;
    $class->new( $self->rs->first->get_columns );
}
sub next_new {
    my $self = shift;
    my $class = $self->class_name;
    $class->new( $self->rs->next->get_columns );
}

1;

