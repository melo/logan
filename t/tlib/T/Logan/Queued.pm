package T::Logan::Queued;

use Moo;
extends 'Log::Logan';
with 'T::Dispatch::Queue';

1;
