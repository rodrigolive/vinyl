use strict;
use warnings;
use Test::More;

use lib 't/lib_dbic';
use lib 't/lib_model';

use Vinyl::Model;
my $model = Vinyl::Model->new( namespace=>'Model' );
is_deeply [ sort $model->module_list ], ['Model::Project', 'Model::User'], 'model loaded';

use Vinyl::Store::DBICe;
#my $store = Vinyl::Store::DBICe->connect('dbi:Oracle://localhost:1521/scm', gbp =>'gbp' );
my $store = Vinyl::Store::DBICe->connect('dbi:SQLite::memory:');

# load dbic schema classes
require Schema::Result::Project;
require Schema::Result::User;
$store->register_class( 'project' => 'Schema::Result::Project' );
$store->register_class( 'user' => 'Schema::Result::User' );
$store->deploy;

# create da session
use Vinyl::Session;
Vinyl::Session->static( model=>$model, store=>$store );

# do stuff
{
    my $prja = Model::Project->new( id=>1, name=>'APRJ' );
    my $prjb = Model::Project->new( id=>2, name=>'BPRJ' );
    $prja->save;
    $prjb->save;
    is Model::Project->search->count => 2, 'count 2';
}
{
    my @bprj = map { $_->name } Model::Project->search({ name=>{ not_like => 'A%' } })->all;
    is_deeply \@bprj, [ 'BPRJ' ], 'search';
}
{
    Model::Project->search({ name=>{ like => 'greatest' } })->delete;
}

done_testing;
