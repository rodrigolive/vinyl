package Role::Dee;
use Moose::Role;
requires 'dee';
sub doo { 
    "[" . shift->name . "]"
}

package Schema::Result::Project;
use Moose;
use DBIx::Class::MooseColumns;
use namespace::autoclean;
extends 'DBIx::Class::Core';
with 'Role::Dee';
 
__PACKAGE__->table('project');
 
has id => (
  isa => 'Int',
  is  => 'rw',
  add_column => {
    is_auto_increment => 1,
  },
);
has name      => ( isa => 'Str', is => 'rw', add_column => {} );
has id_leader => ( isa => 'Int', is => 'rw', add_column => { is_nullable => 1 } );
has info      => ( isa => 'Str', is => 'rw', add_column => { is_nullable => 1 } );
has foo => qw/is rw isa Str/;

sub dee { 'dada'}

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to( 'leader' => 'Schema::Result::User', 'id_leader' );
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
