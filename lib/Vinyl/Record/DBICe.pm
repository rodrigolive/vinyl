package Vinyl::Record::DBICe;
use Moose::Role;
use MooseX::ClassAttribute;
use MooseX::Types::DBIx::Class qw/Row ResultSet/;

class_has 'rs' => (
    is=>'rw', isa=>ResultSet,
    #handles=>[qw/search find/]
    handles  => [ qw/all find first reset next search delete count/ ],
);

has 'row' => (
    is=>'rw', isa=>Row,
    handles=>[qw/insert create get_from_storage/]
);

around 'search' => sub {
    my $orig = shift;
    my $self = shift;
    my $rs = $self->$orig( @_ );
    Vinyl::Set::DBICe->new( class_name=>$self->class_name, rs=>$rs );
};

around [qw(find)] => sub {
    my $orig = shift;
    my $self = shift;
    my $row = $self->$orig( @_ );
    my $obj = $row ? bless( { $row->get_columns } => $self->class_name ) : $row;
    return undef unless ref $obj;
    $obj->row( $row );
    $obj->load_relationships;
    $obj;
};

around get_from_storage => sub {
    my $orig = shift;
    my $self = shift;
    my $row = $self->$orig( @_ );
    return unless $row;
    $self->load_with_accessors( $row->get_columns );
};

with 'Vinyl::Role::Record';

sub save {
    my $self = shift;
    if( my $row = $self->row ) {   # obj is live
        my $cols = $self->_db_serialize_columns;
        while( my ($k,$v) = each %$cols ) {
            $row->set_column( $k, $v );
        }
        $self->store_relationships;
        $row->update;
    } else {  # obj has not been initialized or is new
        my $row = $self->rs->update_or_create( $self->_db_serialize_columns, @_ );
        $self->row( $row );
        $self->store_relationships;
        return $row;
    }
}

sub find_new {
    my $self = shift;
    my $class = $self->class_name;
    my $row = $self->rs->find( @_ );
    my $obj = $class->new( $row->get_columns );
    $obj->row( $row );
    return $obj;
}

sub _db_serialize_columns {
    my $self = shift;
    my %column;
    for my $attr ( $self->meta->get_all_attributes ) {
        my $name = $attr->name;
        $column{ $name } = $self->$name if $attr->does('Vinyl::Column');
    }
    #return { id=>$self->id, name=>$self->name };  # XXX only columns that "does"
    return \%column;
}

1;



