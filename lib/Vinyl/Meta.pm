package Vinyl::Meta;
use Moose;

has 'resource' => ( is=>'rw', isa=>'Str' );
has 'session' => ( is=>'rw', isa=>'Vinyl::Role::Session' );

1;
