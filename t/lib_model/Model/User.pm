package Model::User;
use Vinyl;
with 'Vinyl::Record';

resource 'user';

has_column id => (is => 'rw');
has_column 'password';
has_column username => (
    is      => 'rw',
    isa     => 'Str',
);

has_one project_owned  => 'Maybe[Model::Project]';

1;

