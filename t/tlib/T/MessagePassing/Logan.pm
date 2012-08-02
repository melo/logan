package T::MessagePassing::Logan;

use Moo;
use Message::Passing::Output::Test;
extends 'Logan';
with 'Logan::Dispatch::Message::Passing';

sub default_no_filter_should_dispatch {1}
sub build_message_passing_dispatcher  { Message::Passing::Output::Test->new }

1;
