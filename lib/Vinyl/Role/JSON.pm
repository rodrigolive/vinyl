package Vinyl::Role::JSON;
use Moose::Role;

sub to_json {
    my $self = shift;
    require JSON;
    JSON::to_json( { %$self }, { allow_blessed=>1, convert_blessed=>1 } );
}

sub from_json {
    my $self = shift;
    require JSON;
    my $data = JSON::from_json( shift() );
    bless $data => $self->class_name;
}


1;
