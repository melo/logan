#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::MetaCache::Logan;

subtest 'basic usage' => sub {
  my $lg = T::MetaCache::Logan->instance;
  my $l  = $lg->session;
  my $q  = $lg->queue;

  cmp_deeply($lg->meta_cache, {}, 'cache starts empty');
  for my $was_calculated (1, 0) {
    $l->event({ class => 'c', subclass => 'sc' });
    cmp_deeply(
      $q->[-1],
      superhashof(
        { class    => 'c',
          subclass => 'sc',
          msg      => '',
          data     => {},
          category => 'main',
          twist    => $$,
        }
      ),
      "for calculated == $was_calculated, event matches our expectations",
    );
    ok(!($was_calculated xor $q->[-1]{twist_calculated}), '... and so does our calculated flag');
  }
};


subtest 'no overrides' => sub {
  my $lg = T::MetaCache::Logan->setup;    ## forces clean cache
  my $l  = $lg->session;
  my $q  = $lg->queue;

  cmp_deeply($lg->meta_cache, {}, 'cache starts empty');
  for my $was_calculated (0, 0) {
    $l->event({ class => 'c', subclass => 'sc', twist => 42 });
    cmp_deeply(
      $q->[-1],
      superhashof(
        { class    => 'c',
          subclass => 'sc',
          msg      => '',
          data     => {},
          category => 'main',
          twist    => 42,
        }
      ),
      "event used our twist arg...",
    );
    ok(!exists $q->[-1]{twist_calculated}, '... calculation skipped');
  }
};


done_testing();
