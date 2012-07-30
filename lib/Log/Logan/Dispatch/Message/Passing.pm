package Log::Logan::Dispatch::Message::Passing;

use Moo::Role;
use namespace::clean;

requires 'build_message_passing_dispatcher';

has '_mp_output' => (is => 'lazy', builder => 'build_message_passing_dispatcher');

sub dispatch {
    shift->_mp_output->consume(shift);
}


1;
