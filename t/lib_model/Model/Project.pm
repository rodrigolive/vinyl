package Model::Project;
use Vinyl;
with 'Vinyl::Record';

resource 'project';

has_column id => is => 'rw';
has_column name => (
    is      => 'rw',
    isa     => 'Str',
    trigger => sub { $_[ 0 ]->foo( 'booo' ) }
);
has foo => is => 'rw';

1;
