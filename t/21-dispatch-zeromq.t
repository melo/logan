#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use JSON::XS 'decode_json';
use ZeroMQ ':all';
use lib 't/tlib';
use T::ZeroMQ::Logan;

subtest 'basic events' => sub {
  my $lg = T::ZeroMQ::Logan->new;
  my $sb = _zeromq_subscriber($lg);
  my $s  = $lg->session;

  $s->event({ class => 'c', subclass => 'cs', msg => 'my message' });

  my $msgs = _zeromq_read_pending_messages($sb);
  cmp_deeply(
    $msgs->[-1],
    { topic => 'c.cs', message => superhashof({ class => 'c', subclass => 'cs', category => 'main' }) },
    'received message properly'
  );

  $s->event({ topic_key => 'tk', class => 'c', subclass => 'cs', msg => 'my message' });

  $msgs = _zeromq_read_pending_messages($sb);
  cmp_deeply(
    $msgs->[-1],
    { topic => 'tk', message => superhashof({ class => 'c', subclass => 'cs', category => 'main' }) },
    'received message properly'
  );
};


done_testing();

sub _zeromq_subscriber {
  my ($lg) = @_;
  my $ctx  = $lg->_zmq_context;       ## Private, just for test purposes
  my $sub  = $ctx->socket(ZMQ_SUB);
  $sub->setsockopt(ZMQ_SUBSCRIBE, '');
  $sub->bind($lg->default_zeromq_connect_addr);

  return $sub;
}

sub _zeromq_read_pending_messages {
  my ($sock) = @_;

  select(undef, undef, undef, .100);    ## sleep 100ms to let ZeroMQ do its thing

  my @messages;
  while (1) {
    my $topic = $sock->recv(ZMQ_NOBLOCK);
    last unless defined $topic;         ## FIXME: should check $! == EAGAIN

    my $payload = $sock->recv();
    push @messages, { topic => $topic->data, message => decode_json($payload->data) };
  }

  return \@messages;
}
