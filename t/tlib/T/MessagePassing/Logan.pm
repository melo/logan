package T::MessagePassing::Logan;

use Moo;
extends 'Logan';
with 'Logan::Dispatch::Message::Passing';

use Message::Passing::Output::Test;

sub build_message_passing_dispatcher { Message::Passing::Output::Test->new }

1;
