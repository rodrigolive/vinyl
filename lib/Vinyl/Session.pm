package Vinyl::Session;
use Moose;
use Moose::Util::TypeConstraints;

has model => (
    is       => 'rw',
    isa      => 'Vinyl::Model',
    required => 1
);

has store => (
    is       => 'rw',
    isa      => 'Vinyl::Role::Store',
    required => 1
);

has session_type => (
    is      => 'rw',
    isa     => enum( [ qw[static dynamic] ] ),
    default => 'dynamic'
);

with 'Vinyl::Role::Session';

no Moose;

sub static {
    my ($self, %args) = @_;
    
    $args{session_type} = 'static';
    my $session = __PACKAGE__->new( %args );
    $session->static_setup;
}

sub static_setup {
    my $self = shift;
    for my $module ( $self->model->module_list ) {
        my $vmeta = $module->meta->{vinyl};
        $vmeta->session( $self );   # static models have the session weakref stored
        if( $module->does('Vinyl::Record') ) {
            require Vinyl::Record::DBICe;
            Moose::with( $module->meta, 'Vinyl::Record::DBICe' );
            my $rs = $self->store->resource( $vmeta->resource );
            $module->rs( $rs );
        }
    }
}

sub rs_for_module {
    my ($self, $module) = @_;
    $self->store->resource( $module->meta->{vinyl_resource} );
}

{
    package Vinyl::Session::LiveRecord;
    use Moose;
    use Carp;
    has session => ( is=>'rw', isa=>'Vinyl::Session', required=>1, weak_ref=>1 );
    has module  => ( is=>'rw', does=>'Vinyl::Record', required=>1  );
    our $AUTOLOAD;
    sub rs {
        my ($self) = @_;
        return $self->rs_for_module( $self->module ); 
    }
    sub AUTOLOAD {
        my $self = shift;
        my $name = $AUTOLOAD =~ /(\w+)$/ ? $1 : croak "Invalid method \"$AUTOLOAD\"";
        $self->module->$name( @_ ); 
    }
}

sub get {
    my ($self, $module) = @_;
    $module->rs( $self->store->resource( $module->meta->{vinyl_resource} ) );
    Vinyl::Session::LiveRecord->new( module=>$module , session=>$self );
}

1;
