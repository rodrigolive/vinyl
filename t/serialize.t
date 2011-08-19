use strict;
use warnings;

use lib 't/lib_model';
use Test::More;

use Vinyl::Model;
my $model = Vinyl::Model->new( namespace=>'Model' );
use Model::Project;
my $prj = Model::Project->new( name=>'abc' );
my $json = $prj->to_json;
ok $json =~ /\{.+\}/, 'serialize';
my $p2 = Model::Project->from_json( $json );
is $p2->name, 'abc', 'deserialize ok';

done_testing;
