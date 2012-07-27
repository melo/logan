#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Simple::Logan;

my $lg = T::Simple::Logan->instance;
my $l  = $lg->session;
my $q  = $lg->queue;

my $c = 0;
for my $m (qw( authorized denied create delete updated )) {
  $l->$m("$m message", { a => ++$c });
  cmp_deeply(
    $q->[-1],
    superhashof(
      { class    => 'audit',
        subclass => $m,
        msg      => "$m message",
        data     => { a => $c },
      }
    ),
    "audit $m() ok"
  );
}


done_testing();
