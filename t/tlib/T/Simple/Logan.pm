package T::Simple::Logan;

use Moo;
extends 'Log::Logan';
with 'Log::Logan::ID::UUID', 'T::Dispatch::Queue';

1;
