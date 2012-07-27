package T::Simple::Logan;

use Moo;
extends 'Log::Logan';
with 'T::Dispatch::Queue';

1;
