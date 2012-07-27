package MyLogan;

use Moo;
extends 'Log::Logan';
with 'Log::Logan::ID::UUID', 'MySimpleDispatchQueue';

1;
