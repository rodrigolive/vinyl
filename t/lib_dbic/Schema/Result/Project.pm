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
 
__PACKAGE__->table('bali_project');
 
has id => (
  isa => 'Int',
  is  => 'rw',
  add_column => {
    is_auto_increment => 1,
  },
);
has name => ( isa => 'Str', is  => 'rw', add_column=>{} );
has 'foo' => qw/is rw isa Str/;
sub dee { 'dada'}

__PACKAGE__->set_primary_key('id');
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
