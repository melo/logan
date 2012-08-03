#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Simple::Logan;
use T::Simple::Session;


subtest 'logger creation' => sub {
  my $lg = T::Simple::Logan->instance;

  my $l1 = $lg->session;
  ok($l1, 'Got a logger...');
  is(ref($l1), 'Logan::Session', '... of the expected default Logger class');

  is($l1->logan, $lg, 'logan attr keeps track of the Logan obj that created us');
  like($l1->id, qr{^[a-fA-F0-9-]{36}$}, '... and the id attr looks like a UUID');

  my $l2 = $lg->session(id => 42);
  is($l2->id, 42, 'attr id can be set when calling Logan->session()');

  my $l3 = T::Simple::Logan->session;
  is($l3->logan, $l1->logan, 'logger() as class methods uses Logan instance for class');

  my $l4 = T::Simple::Logan->session(logan => 'xpto');
  is($l4->logan, $l1->logan, 'logger() ignores logan attr');

  $lg = T::Simple::Logan->setup(session_class => 'T::Simple::Session');
  ok($lg, 'Change default logger class');
  my $l5 = $lg->session;
  ok($l5, '... get a new logger...');
  is(ref($l5), 'T::Simple::Session', '... and it is the new Logger class, magic!');
  is($l5->logan, $lg, '... with the expected new Logan obj');
};


subtest 'events' => sub {
  my $lg = T::Simple::Logan->setup;    ### Make sure we have a new clean instance
  my $l  = $lg->session;
  my $q  = $lg->queue;

  ok($l->event({ class => 'log', subclass => 'me' }), 'simple event sent ok');
  cmp_deeply(
    $q->[-1],
    { class    => 'log',
      subclass => 'me',
      msg      => '',
      args     => {},
      caller   => ignore(),
      category => 'main',
      tstamp   => [num(time(), 1), re(qr{^\d+$})],
    },
    '... found expected event structure'
  );

  ok($l->event({ class => 'log', subclass => 'me', msg => 'msg' }), 'Event wiht message sent ok');
  cmp_deeply(
    $q->[-1],
    { class    => 'log',
      subclass => 'me',
      msg      => 'msg',
      args     => {},
      caller   => ignore(),
      category => 'main',
      tstamp   => [num(time(), 1), re(qr{^\d+$})],
    },
    '... found expected event structure'
  );

  ok($l->event({ class => 'log', subclass => 'me', msg => 'msg', args => { a => 1, b => 2 } }),
    'Event with message and event args sent ok');
  cmp_deeply(
    $q->[-1],
    { class    => 'log',
      subclass => 'me',
      msg      => 'msg',
      args     => { a => 1, b => 2 },
      caller   => ignore(),
      category => 'main',
      tstamp => [num(time(), 1), re(qr{^\d+$})],
    },
    '... found expected event structure'
  );

  ok($l->event(class => 'log'), 'Event with just class, as hash, sent ok');
  cmp_deeply(
    $q->[-1],
    { class    => 'log',
      msg      => '',
      args     => {},
      caller   => ignore(),
      category => 'main',
      tstamp   => [num(time(), 1), re(qr{^\d+$})],
    },
    '... found expected event structure'
  );

  ok($l->event(class => 'log', subclass => 'me', msg => 'msg', args => { a => 1, b => 2 }),
    'Event with message and event args, as hash sent ok');
  cmp_deeply(
    $q->[-1],
    { class    => 'log',
      subclass => 'me',
      msg      => 'msg',
      args     => { a => 1, b => 2 },
      caller   => ignore(),
      category => 'main',
      tstamp => [num(time(), 1), re(qr{^\d+$})],
    },
    '... found expected event structure'
  );
};


done_testing;
