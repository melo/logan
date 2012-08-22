package Logan::Dispatch::ZeroMQ;

use Moo::Role;
use ZeroMQ ':all';
use JSON::XS 'encode_json';
use namespace::autoclean;

requires 'default_zeromq_connect_addr';

has 'connect_addr' => (is => 'lazy');
has '_zmq_context' => (is => 'lazy');
has '_zmq_sock'    => (is => 'lazy');

sub _build_connect_addr { shift->default_zeromq_connect_addr }

sub _build__zmq_context { ZeroMQ::Context->new }

sub _build__zmq_sock {
  my ($self) = @_;
  my $addr = $self->connect_addr;
  return unless $addr;

  my $sock = $self->_zmq_context->socket(ZMQ_PUB);
  $sock->connect($addr);

  return $sock;
}

sub dispatch {
  my ($self, $ev) = @_;

  ## TODO: allow $ev->{key}: if it exists, use it
  my $key = $ev->{class};
  $key .= '.' . $ev->{subclass} if defined $ev->{subclass};

  ## FIXME: switch to key\0message: multi-part messages are deprecated
  ## by both ZeroMQ and CrossRoads IO projects
  my $sock = $self->_zmq_sock;
  $sock->send($key, ZMQ_SNDMORE);
  $sock->send(encode_json($ev));
}


1;
