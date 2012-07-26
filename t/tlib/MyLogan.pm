package MyLogan;

use Moo;
extends 'Log::Logan';
with 'Log::Logan::ID::UUID', 'MySimpleDispatchQueue';

sub dispatch { shift->queue_message(@_) }

1;
