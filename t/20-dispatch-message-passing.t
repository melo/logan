#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::MessagePassing::Logan;


subtest 'basic events' => sub {
  my $lg = T::MessagePassing::Logan->new;
  my $to = $lg->_mp_output;                    ## Private, just for test purposes
  my $l  = $lg->session;

  is($to->message_count, 0, 'no messages recorded at start');

  $l->event({ class => 'c', subclass => 'cs' });
  cmp_deeply(
    [$to->messages],
    [superhashof({ class => 'c', subclass => 'cs', category => 'main' })],
    'event() sent a proper message'
  );
};


done_testing();
