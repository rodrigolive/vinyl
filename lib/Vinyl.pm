package Vinyl;
use Moose ();
use Moose::Exporter;

require Vinyl::Model;
require Vinyl::Session;
require Vinyl::Meta;

Moose::Exporter->setup_import_methods(
    with_meta => [qw(has_column has_one has_many resource)],
    also      => 'Moose',
);

sub resource {
    my $meta = shift;
    my $name = shift;
    my $class = $meta->name;
    $meta->{vinyl} ||= Vinyl::Meta->new;
    $meta->{vinyl}->resource( $name );
}

sub has_column {
    my $meta = shift;
    my $name = shift;
    my %options;
    if ( @_ > 0 && @_ % 2 ) {
        $options{isa} = shift;
        $options{is}  = 'rw';
        if( @_ > 1 ) {  # allow: has_one 'att' => 'Str', required=>1;
            %options = ( %options, @_ );
        }
    }
    else {
        %options = @_;
        $options{isa} ||= 'Any';
        $options{is}  ||= 'rw';
    }
    push @{ $options{traits} }, 'Vinyl::Column';

    $meta->add_attribute( $name, %options, );
}

sub has_one {
    my $meta = shift;
    my $name = shift;
    my %options;
    if ( @_ > 0 && @_ % 2 ) {
        $options{isa} = shift;
        $options{is}  = 'rw';
        if( @_ > 1 ) {  # allow: has_one 'att' => 'Str', required=>1;
            %options = ( %options, @_ );
        }
    }
    else {
        %options = @_;
        $options{isa} ||= 'Any';
        $options{is}  ||= 'rw';
    }
    push @{ $options{traits} }, 'Vinyl::Join';

    #TODO make sure the object is a Vinyl::Record 
    #   otherwise it should not be a join but a serialized row instead

    $meta->add_attribute( $name, %options, );
}

sub belongs_to {
    my $meta = shift;
    my $name = shift;
    my %options;
    if ( @_ > 0 && @_ % 2 ) {
        $options{isa} = shift;
        $options{is}  = 'rw';
        if( @_ > 1 ) {  # allow: has_one 'att' => 'Str', required=>1;
            %options = ( %options, @_ );
        }
    }
    else {
        %options = @_;
        $options{isa} ||= 'Any';
        $options{is}  ||= 'rw';
    }
    push @{ $options{traits} }, 'Vinyl::Join', 'Vinyl::Column';

    $meta->add_attribute( $name, %options, );
}

sub has_many {
    my $meta = shift;
    my $name = shift;
    my %options;
    if   ( scalar @_ == 1 ) { $options{isa} = shift; }
    else                    { %options      = @_; }
    
    my $isa_original = $options{isa};
    my $reciprocal = delete $options{reciprocal};
    $options{isa} = 'Vinyl::Join[' . $options{isa} . ']';
    $options{default} ||=
      sub {
          use Vinyl::Join;
          Vinyl::Join->new( with_class => "$isa_original", owner => shift, reciprocal => $reciprocal  );
        };
    $options{is} ||= 'ro';
    $meta->add_attribute( $name, %options, );
}

package Vinyl::Meta::Attribute::Trait::Vinyl::Column; {
    use strict;
    use Moose::Role;
    has 'column' => ( isa => 'Str', is => 'rw', );
    has 'lazy_select' => ( isa => 'Bool', is => 'rw', default => 0, );
}

package Moose::Meta::Attribute::Custom::Trait::Vinyl::Column; {
    sub register_implementation {'Vinyl::Meta::Attribute::Trait::Vinyl::Column'}
}

package Vinyl::Meta::Attribute::Trait::Vinyl::Join; {
    use strict;
    use Moose::Role;
}

package Moose::Meta::Attribute::Custom::Trait::Vinyl::Join; {
    sub register_implementation {'Vinyl::Meta::Attribute::Trait::Vinyl::Join'}
}

=pod

=head1 NAME

Vinyl - An implementation of the Datamapper pattern (Moose + DBIC) 

=head1 SYNOPSIS

    # bind your model classes with your data store
    my $model = Vinyl::Model->new( namespace=>'Model' );
    my $store = Vinyl::Store::DBIC->connect('dbi:SQLite::memory:');
    Vinyl::Session->static( model=>$model, store=>$store );

    # enjoy
    my $obj = Model::Artist->new( name=>'Lou' ); # in ram
    $obj->save; # save to db

=head1 DESCRIPTION

This is a preview release of Vinyl. Don't use this module yet.

This library implements the Datamapper and Repository patterns. 
The idea is to separate your domain model (Moose classes) 
from your data model (SQL calls, ORMs like DBIx::Class or RoseDB, 
NoSQL database or KiokuDB). 

The advantage of using such pattern is that your model object 
instances do not have to know about the underlying implementation. 

The separation is archieved through delegation, which means
your objects will have either a C<rs> or C<row> attribute 
or both. 

The API is heavily influenced by DBIC's own, with nuances
from Rubyishy libraries such as ActiveRecord and DataMapper. 

=cut

1;
