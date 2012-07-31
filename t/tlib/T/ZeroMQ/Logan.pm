package T::ZeroMQ::Logan;

use Moo;
extends 'Logan';
with 'Logan::Dispatch::ZeroMQ';

sub default_zeromq_connect_addr {'ipc://zeromq_test.sock'}

1;
