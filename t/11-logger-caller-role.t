#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use MyLoganForCaller;

my $lg = MyLoganForCaller->instance;
my $q  = $lg->queue;

$lg->simple_caller_test;
cmp_deeply(
  $q->[-1],
  { class    => 'c',
    subclass => 'cs',
    msg      => 'msg',
    data     => {},
    caller   => {
      class  => 'MyLoganForCaller',
      method => 'simple_caller_test',
      file   => re(qr{t/tlib/MyLoganForCaller[.]pm$}),
      line   => num(20, 2),
    },
    category => 'my_logan_for_caller.simple_caller_test',
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
      class  => 'MyLoganForCaller',
      method => 'eval_caller_test',
      file   => re(qr{t/tlib/MyLoganForCaller[.]pm$}),
      line   => num(26, 2),
    },
    category => 'my_logan_for_caller.eval_caller_test',
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
      class  => 'MyLoganForCaller',
      method => 'try_tiny_caller_test',
      file   => re(qr{t/tlib/MyLoganForCaller[.]pm$}),
      line   => num(34, 2),
    },
    category => 'my_logan_for_caller.try_tiny_caller_test',
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
      class  => 'MyLoganForCaller',
      method => 'complex_caller_test',
      file   => re(qr{t/tlib/MyLoganForCaller[.]pm$}),
      line   => num(44, 2),
    },
    category => 'my_logan_for_caller.complex_caller_test',
    tstamp   => [num(time(), 1), re(qr{^\d+$})],
  },
  'event for complex_caller_test() ok'
);


done_testing;
