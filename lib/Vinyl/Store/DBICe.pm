package Vinyl::Store::DBICe;
use Moose;
use Carp;
use namespace::autoclean;

extends 'DBIx::Class::Schema';
with 'Vinyl::Role::Store';

require Vinyl::Set::DBICe;

sub resource {
    my ($self, $resource) = @_;
    $self->resultset( $resource );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
