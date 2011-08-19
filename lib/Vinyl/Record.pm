package Vinyl::Record;
use Moose::Role;

# used by all providers

sub load_with_accessors {
    my ($self, %row ) = @_ ;
    my %attr = map { $_ => 1 } $self->_data_attributes; 
    while( my ($meth, $val) = each %row ) {
        $self->$meth( $val ) if $attr{$meth};
    }
    $self;
};

sub load_relationships {
    my ($self, %row ) = @_ ;
    for my $attr (  $self->_rel_attributes ) {
        my $attr_name = $attr->name;
        my $attr_type = $attr->type_constraint->name;
        my ($class) = $attr_type =~ /Maybe\[(.+)\]/;
        $class ||= $attr_type;
        my $foreign_row = $self->row->$attr_name;
        next unless ref $foreign_row;
        my $foreign_obj = bless { $foreign_row->get_columns } => $class;
        $self->$attr_name( $foreign_obj ); 
    }
};

sub store_relationships {
    my ($self, %row ) = @_ ;
    for my $attr (  $self->_rel_attributes ) {
        my $attr_name = $attr->name;
        my $foreign = $self->$attr_name or next;
        my $foreign_row = $foreign->row;
        $self->row->$attr_name( $foreign_row ) if $foreign_row;
    }
};

sub class_name {
    my $self = shift;
    ref $self || $self;
}

sub _data_attributes {
    my $self = shift;
    my @attr_names;
    for my $attr ( $self->meta->get_all_attributes ) {
        my $name = $attr->name;
        push @attr_names, $name if $attr->does('Vinyl::Column');
    }
    return @attr_names;
}

sub _rel_attributes {
    my $self = shift;
    my @attrs;
    for my $attr ( $self->meta->get_all_attributes ) {
        my $name = $attr->name;
        push @attrs, $attr if $attr->does('Vinyl::Join');
    }
    return @attrs;
}

sub _has_data_attribute {
    my $self = shift;
    my %attr = map { $_ => 1 } $self->_data_attributes; 
    return $attr{ shift() };
}

1;
