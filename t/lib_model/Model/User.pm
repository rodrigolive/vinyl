package Model::User;
use Vinyl;
with 'Vinyl::Record';

resource 'user';

has_column id => is => 'rw';
has_column name => (
    is      => 'rw',
    isa     => 'Str',
);

1;

