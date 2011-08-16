package Vinyl::Role::Set;
use Moose::Role;

requires 'search';
requires 'find';
requires 'delete';
requires 'all';
requires 'first';
requires 'last';
requires 'count';

1;
