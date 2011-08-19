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
#my $store = Vinyl::Store::DBICe->connect('dbi:SQLite::memory:');
my $store = Vinyl::Store::DBICe->connect('dbi:SQLite:v.db');
my $dbh = $store->storage->dbh;

# load dbic schema classes
require Schema::Result::Project;
require Schema::Result::User;
$store->register_class( 'project' => 'Schema::Result::Project' );
$store->register_class( 'user' => 'Schema::Result::User' );
$store->deploy({ add_drop_table => 1 });

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
    my $prj = Model::Project->search({ name=>{ not_like => 'A%' } })->first;
    is ref($prj), 'Model::Project', 'first isa ok';
    is ref($prj->rs), 'DBIx::Class::ResultSet', 'isa resultset';

    $prj = Model::Project->find(1);
    is ref($prj), 'Model::Project', 'find isa ok';
    is $prj->name, 'APRJ', 'find 1 ok';
    is $prj->foo, undef, 'find no trigger ok';

    $prj = Model::Project->find_new(1);
    is $prj->foo, 'bar', 'find_new with trigger ok';

}
{
    my @bprj = map { $_->name } Model::Project->search({ name=>{ not_like => 'A%' } })->all;
    is_deeply \@bprj, [ 'BPRJ' ], 'search';
}
{
    my $prj = Model::Project->find_new(1);
    $dbh->do("update project set name='baz' where id='1'");
    $prj->get_from_storage;
    is $prj->name, 'baz', 'get_from_storage';
}
{
    my $prj = Model::Project->find_new(1);
    my $u = Model::User->new( id=>1, username=>'Homer', password=>'xxxx' );
    $u->save;
    is Model::User->find(1)->username, 'Homer', 'user stored';
    $prj->leader( $u );
    $prj->save;
}
{
    my $prj = Model::Project->find(1);
    my $leader = $prj->leader;
    is ref $leader, 'Model::User', 'rel object';
    is $leader->id, 1, 'rel id';
    is $leader->username, 'Homer', 'rel username';
}
{
    my $u = Model::User->find(1);
    is $u->project_owned->name, 'baz', 'user owns project';
    my $np = Model::Project->new( id=>3, name=>'nuevo' );
    $np->save;
    #TODO project_owned might_have does not work
        #$u->row->project_owned( $np->row );
        #$u->row->username( 'bobo' );
        #$u->row->update;
    #$u->project_owned( $np );
    #$u->save;
}
{
    Model::Project->search({ id=>2 })->delete;
    is Model::Project->find(2), undef, 'deleted'; 
}

done_testing;
