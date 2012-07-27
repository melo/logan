#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Caller::Logan;

my $lg = T::Caller::Logan->instance;
my $q  = $lg->queue;

$lg->simple_caller_test;
cmp_deeply(
  $q->[-1],
  { class    => 'c',
    subclass => 'cs',
    msg      => 'msg',
    data     => {},
    caller   => {
      class  => 'T::Caller::Logan',
      method => 'simple_caller_test',
      file   => re(qr{t/tlib/T/Caller/Logan[.]pm$}),
      line   => num(20, 2),
    },
    category => 't.caller.logan.simple_caller_test',
    tstamp   => [num(time(), 1), re(qr{^\d+$})],
  },
  'event for simple_caller_test() ok'
);


$lg->eval_caller_test;
cmp_deeply(
  $q->[-1],
  { class    => 'c',
    subclass => 'cs',
    msg      => 'msg',
    data     => {},
    caller   => {
      class  => 'T::Caller::Logan',
      method => 'eval_caller_test',
      file   => re(qr{t/tlib/T/Caller/Logan[.]pm$}),
      line   => num(26, 2),
    },
    category => 't.caller.logan.eval_caller_test',
    tstamp   => [num(time(), 1), re(qr{^\d+$})],
  },
  'event for eval_caller_test() ok'
);


$lg->try_tiny_caller_test;
cmp_deeply(
  $q->[-1],
  { class    => 'c',
    subclass => 'cs',
    msg      => 'msg',
    data     => {},
    caller   => {
      class  => 'T::Caller::Logan',
      method => 'try_tiny_caller_test',
      file   => re(qr{t/tlib/T/Caller/Logan[.]pm$}),
      line   => num(34, 2),
    },
    category => 't.caller.logan.try_tiny_caller_test',
    tstamp   => [num(time(), 1), re(qr{^\d+$})],
  },
  'event for try_tiny_caller_test() ok'
);


$lg->complex_caller_test;
cmp_deeply(
  $q->[-1],
  { class    => 'c',
    subclass => 'cs',
    msg      => 'msg',
    data     => {},
    caller   => {
      class  => 'T::Caller::Logan',
      method => 'complex_caller_test',
      file   => re(qr{t/tlib/T/Caller/Logan[.]pm$}),
      line   => num(44, 2),
    },
    category => 't.caller.logan.complex_caller_test',
    tstamp   => [num(time(), 1), re(qr{^\d+$})],
  },
  'event for complex_caller_test() ok'
);


done_testing;
