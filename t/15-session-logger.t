#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use MyLogan;

my $lg = MyLogan->instance;
my $l  = $lg->logger;
my $q  = $lg->queue;

my $c = 0;
for my $m (qw( trace debug info warn error critical fatal )) {
  $l->$m("$m message", { a => ++$c });
  cmp_deeply(
    $q->[-1],
    superhashof(
      { class    => 'logger',
        subclass => $m,
        msg      => "$m message",
        data     => { a => $c },
      }
    ),
    "$m() ok"
  );
}


done_testing();
