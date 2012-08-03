package Logan::Dispatch::Message::Passing;

use Moo::Role;
use namespace::autoclean;

requires 'build_message_passing_output';

has '_mp_output' => (is => 'lazy', builder => 'build_message_passing_output');

sub dispatch {
    shift->_mp_output->consume(shift);
}


1;
