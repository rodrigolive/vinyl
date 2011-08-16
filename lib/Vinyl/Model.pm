package Vinyl::Model;
use Moose;

has namespace => ( is => 'rw', isa => 'Str', required => 1 );
has modules   => is => 'rw',
    isa       => 'ArrayRef[Str]',
    traits    => [ 'Array' ],
    handles => { find => 'grep', join => 'join', module_list => 'elements' };

sub BUILD {
    my $self = shift;
    #my @modules = $self->load_schema( search_path => $self->namespace );
    my @modules = $self->load_model_namespace( search_path => $self->namespace );
    $self->modules( \@modules );
}

sub load_model_namespace {
    my ($self, %args ) = @_;
    require Module::Find;
    my $shorten = delete $args{shorten};
    my $search_path = delete $args{search_path};
    my @mods = Module::Find::findallmod($search_path);
    my @modules;
    for my $module ( @mods ) {
        eval "require $module";
        croak $@ if $@;
        if ( $shorten && $module =~ m/$search_path\:\:(.*?)$/ ) {
            my $short_name = $1;
            no strict 'refs';
            *{ $short_name . "::" } = \*{ $module . "::" };
            $short_name->meta->{vinyl} =
              $module->meta->{vinyl};
            push @modules, $short_name;
        } else {
            push @modules, $module;
        }
    }
    return @modules;
}

sub load_schema {
    my ( $self, %args ) = @_;
    require Module::Pluggable;
    my $shorten = delete $args{shorten};
    my $search_path = delete $args{search_path};
    Module::Pluggable->import( search_path => $search_path );
    my @modules;
    for my $module ( $self->plugins ) {
        eval "require $module";
        croak $@ if $@;
        if ( $shorten && $module =~ m/$search_path\:\:(.*?)$/ ) {
            my $short_name = $1;
            no strict 'refs';
            *{ $short_name . "::" } = \*{ $module . "::" };
            $short_name->meta->{vinyl} =
              $module->meta->{vinyl};
            push @modules, $short_name;
        } else {
            push @modules, $module;
        }
    }
    @modules;
}

1;
