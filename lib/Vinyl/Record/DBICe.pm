package Vinyl::Record::DBICe;
use Moose::Role;
use MooseX::ClassAttribute;
use MooseX::Types::DBIx::Class qw/Row ResultSet/;

class_has 'rs' => (
    is=>'rw', isa=>ResultSet,
    handles=>[qw/search find/]
);

has 'row' => (
    is=>'rw', isa=>Row,
    handles=>[qw/insert create delete/]
);

around 'search' => sub {
    my $orig = shift;
    my $self = shift;
    my $rs = $self->$orig( @_ );
    Vinyl::Set::DBICe->new( class_name=>$self->class_name, rs=>$rs );
};

around 'find' => sub {
    my $orig = shift;
    my $self = shift;
    my $row = $self->$orig( @_ );
    $row ? bless( { %$row }, $self->class_name ) : $row;
};

sub class_name {
    my $self = shift;
    ref $self || $self;
}
sub save {
    my $self = shift;
    #my $row = $self->rs->new( $self->_db_serialize_columns );
    #$row->insert;
    $self->rs->update_or_create( $self->_db_serialize_columns, @_ );
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



