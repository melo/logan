#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Fatal;
use lib 't/tlib';
use T::Simple::Logan;


my $lg = T::Simple::Logan->setup;    ### Make sure we have a new clean instance
my $l  = $lg->session;
my $q  = $lg->queue;

ok(
  $l->event(
    { class    => 'c',
      subclass => 'sc',
      msg      => 'me #{undef_key} for #{scalar_key} with #{ref_key}',
      args     => { undef_key => undef, scalar_key => '42', ref_key => { question => '?' } },
    }
  ),
  'simple event sent ok'
);
cmp_deeply(
  $q->[-1],
  { class    => 'c',
    subclass => 'sc',
    msg      => 'me <undef> for 42 with { question => "?" }',
    args     => { undef_key => undef, scalar_key => '42', ref_key => { question => '?' } },
    caller   => ignore(),
    category => 'main',
    tstamp => [num(time(), 1), re(qr{^\d+$})],
  },
  '... found expected event message'
);

like(
  exception { $l->event({ class => 's', subclass => 'sc', msg => 'no such #{key}' }) },
  qr{^Event message has 'key' field, but no such field found on event args,},
  'placeholders missing from event args will kill you'
);


done_testing;
