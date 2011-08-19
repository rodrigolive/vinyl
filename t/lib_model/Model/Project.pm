package Model::Project;
use Vinyl;
with 'Vinyl::Record';
with 'Vinyl::Role::JSON';

resource 'project';

has_column id => is => 'rw';
has_column name => (
    is      => 'rw',
    isa     => 'Str',
    trigger => sub { $_[ 0 ]->foo( 'bar' ) }
);
has foo => ( is => 'rw' ); 

has_one  leader  => 'Maybe[Model::User]';
has_many members => 'Model::User';

1;
