#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Fatal;
use lib 't/tlib';
use T::Simple::Logan;


subtest 'data is per session' => sub {
  my $lg = T::Simple::Logan->setup;
  my $s1 = $lg->session;
  my $s2 = $lg->session;

  ## FIXME: needs proper test after set_data: we only get clones, always diff
  isnt($s1->data, $s2->data, 'each session gets his own data');
};


subtest 'data: safe defaults, safe to query' => sub {
  my $lg = T::Simple::Logan->setup;
  my $s  = $lg->session;

  cmp_deeply($s->data, {}, 'no data by default');
  cmp_deeply($s->data('a_key', 'b_key'), {}, 'fetching non-existing keys, returns empty hash also');
  cmp_deeply($s->data, {}, 'no auto-vivication bugs either');

  ## force destruction
  undef $s;

  cmp_deeply(
    $lg->queue,
    [superhashof({ class => 'data', subclass => 'create', args => {} })],
    'only one change event generated, create'
  );
};


subtest 'data init and query' => sub {
  my $lg = T::Simple::Logan->setup;
  my $s = $lg->session(data => { owners => 'mice', answer => 42, question => 'tbd' });

  cmp_deeply(
    $s->data,
    { owners => 'mice', answer => 42, question => 'tbd' },
    'data can be initializaed at session build time'
  );
  cmp_deeply(
    $s->data(qw(question answer timeline)),
    { answer => 42, question => 'tbd' },
    'specific fields can also be retrieved'
  );
};


subtest 'data is shallow clone' => sub {
  my $lg = T::Simple::Logan->setup;
  my $s = $lg->session(data => { shallow => {} });

  my $d = $s->data;
  cmp_deeply($d, { shallow => {} }, 'data starts with a single key');
  $d->{cool}++;
  cmp_deeply($s->data, { shallow => {} }, 'data still has one key after direct manipulation');

  $d = $s->data('shallow');
  $d->{cool}++;
  cmp_deeply($s->data, { shallow => {} }, 'data still has one key after direct manipulation of selection');

  $d = $s->data('shallow');
  $d->{shallow}{deep} = 42;
  cmp_deeply($s->data, { shallow => { deep => 42 } }, 'but the clone we get from data() is only shallow');
};


subtest 'set data' => sub {
  my $lg = T::Simple::Logan->setup;
  my $s  = $lg->session;

  cmp_deeply($s->data, {}, 'data starts empty');

  $s->set_data(k => 'v', z => 'y');
  cmp_deeply($s->data, { k => 'v', z => 'y' }, 'data_set() with k/v pair works');

  $s->set_data(z => 'x', s => { t => 1 });
  cmp_deeply($s->data, { k => 'v', z => 'x', s => { t => 1 } }, 'data_set() with k/v pair merges with current data');

  $s->set_data(s => { y => 1 });
  cmp_deeply($s->data, { k => 'v', z => 'x', s => { y => 1 } }, 'but data_set() with k/v pair merge is shallow');

  $s->set_data({ answer => 42 });
  cmp_deeply($s->data, { answer => 42 }, 'set_data() with single HashRef param overrides all data');

  ## force destruction
  undef $s;

  cmp_deeply(
    $lg->queue,
    [ superhashof({ class => 'data', subclass => 'create', args => {} }),
      superhashof({ class => 'data', subclass => 'update', args => { k => 'v', z => 'y' } }),
      superhashof({ class => 'data', subclass => 'update', args => { k => 'v', z => 'x', s => { t => 1 } } }),
      superhashof({ class => 'data', subclass => 'update', args => { k => 'v', z => 'x', s => { y => 1 } } }),
      superhashof({ class => 'data', subclass => 'update', args => { answer => 42 } }),
    ],
    'one change event per change, plus create'
  );
};


subtest 'bad/strange set_data() calls' => sub {
  my $lg = T::Simple::Logan->setup;
  my $s  = $lg->session;

  is(exception { $s->set_data }, undef, 'calling set_data() without args does nothing');

  like(
    exception { $s->set_data(1) },
    qr{^\QSingle parameter call to set_data() must be a HashRef,\E},
    'calling set_data() with single param dies, must be HashRef'
  );
  like(
    exception { $s->set_data(1, 2, 3) },
    qr{^\Qset_data() accepts with a Hash or a HashRef: odd-number of params detected,\E},
    'calling set_data() with odd-number of param dies, must be list of pairs (even-number of params)'
  );
};


subtest 'export sanity' => sub {
  my $lg = T::Simple::Logan->setup;
  ok(!$lg->session->can('_trigger_change_update'), 'private _trigger_change_update is hidden from users');
};


done_testing();
