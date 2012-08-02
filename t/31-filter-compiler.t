#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::LongString;
use lib 't/tlib';
use T::Simple::Logan;
use Logan::Filter::Compiler;

subtest 'condition atom' => sub {
  my $c = Logan::Filter::Compiler->new;
  my $m = Logan::Filter::Compiler::State->new;

  cmp_deeply([$c->_emit_condition_atom('class', undef, { class => undef }, $m)], [], 'atom with undef values, skipped');

  cmp_deeply(
    [$c->_emit_condition_atom('class', 'me', { class => 'me' }, $m)],
    ['$a1', 'my $a1 = $e->{"class"} eq "me";'],
    'class atom generated ok'
  );
  cmp_deeply(
    [$c->_emit_condition_atom('subclass', 'me', { subclass => 'me' }, $m)],
    ['$a2', 'my $a2 = $e->{"subclass"} eq "me";'],
    'subclass atom generated ok'
  );

  cmp_deeply(
    [$c->_emit_condition_atom('category', 'me', { category => 'me' }, $m)],
    ['$a3', 'my $a3 = exists $e->{"category"} and defined $e->{"category"} and $e->{"category"} eq "me";'],
    'category atom generated ok'
  );

  cmp_deeply([$c->_emit_condition_atom('subclass', 'me', { subclass => 'me' }, $m)],
    ['$a2'], 'duplicate condition atoms dont emit nothing');
};


subtest 'condition code' => sub {
  my $c = Logan::Filter::Compiler->new;
  my $m = Logan::Filter::Compiler::State->new;

  is_string(
    $c->_compile_condition({ condition => { class => 'log', xpto => undef } }, $m),
    'my $a1 = $e->{"class"} eq "log"; if ($a1) ',
    '_compile_condition() generates proper code, incl condition atom init code, undef values skipped',
  );
  is_string(
    $c->_compile_condition({ condition => { class => 'log', subclass => 'critical' } }, $m),
    'my $a2 = $e->{"subclass"} eq "critical"; if ($a1 and $a2) ',
    'init code is generated only once for duplicate expressions',
  );
};


subtest 'command code' => sub {
  my $c = Logan::Filter::Compiler->new;

  cmp_deeply([$c->_emit_command(dispatch => 'true')], ['$s->{should_dispatch} = 1;', 1], 'command dispatch => true ok');
  cmp_deeply(
    [$c->_emit_command(dispatch => 'false')],
    ['$s->{should_dispatch} = 0;', 1],
    'command dispatch => false ok',
  );

  cmp_deeply(
    [$c->_emit_command(use => 'xpto')],
    ['unshift @{$s->{cfgs_to_check}}, "xpto";', 0],
    'command use => "config_name" ok'
  );

  cmp_deeply(
    [$c->_emit_command(enable => '$xpto')],
    ['$s->{cfgs_session}{"\$xpto"} = 1;', 0],
    'command enable => "config_name" ok'
  );

  cmp_deeply(
    [$c->_emit_command(disable => '$xpto')],
    ['delete $s->{cfgs_session}{"\$xpto"};', 0],
    'command disable => "config_name" ok'
  );

  cmp_deeply([$c->_emit_command(final => 'yes')], ['', 1], 'command final => yes ok');
  cmp_deeply([$c->_emit_command(final => 'no')],  ['', 0], 'command final => no ok',);
};


subtest 'action code' => sub {
  my $c = Logan::Filter::Compiler->new;

  is_string(
    $c->_compile_action({ action => { disable => 'zbr', dispatch => 'no' } }),
    'delete $s->{cfgs_session}{"zbr"};$s->{should_dispatch} = 0;return;',
    'action { disable => "zbr", dispatch => "no" } ok',
  );
  is_string(
    $c->_compile_action({ action => { dispatch => 'yes', enable => 'xpto' } }),
    '$s->{should_dispatch} = 1;$s->{cfgs_session}{"xpto"} = 1;return;',
    'action { dispatch => "yes", enable => "xpto" } ok',
  );
  is_string(
    $c->_compile_action({ action => { use => '$ypto', enable => 'ypto', final => 1 } }),
    '$s->{cfgs_session}{"ypto"} = 1;unshift @{$s->{cfgs_to_check}}, "\$ypto";return;',
    'action { enable => "ypto", use => "\$ypto", final => 1 } ok',
  );
};


subtest 'rule code' => sub {
  my $c = Logan::Filter::Compiler->new;
  my $m = Logan::Filter::Compiler::State->new;

  is_string(
    $c->_compile_rule({ action => { dispatch => 0 } }, $m),
    '{ $s->{should_dispatch} = 0;return; }',
    'rule { action => { dispatch => 0 }} ok',
  );

  is_string(
    $c->_compile_rule({ condition => { class => 'xpto' }, action => { dispatch => 0 } }, $m),
    'my $a1 = $e->{"class"} eq "xpto"; if ($a1) { $s->{should_dispatch} = 0;return; }',
    'rule { condition => { class=>"xpto" }, action => { dispatch => 0 } } ok',
  );

  is_string(
    $c->_compile_rule(
      { condition => {
          class    => 'xpto',
          subclass => 'me',
        },
        action => {
          enable => 'yo',
          final  => 1,
        }
      },
      $m
    ),
    'my $a2 = $e->{"subclass"} eq "me"; if ($a1 and $a2) { $s->{cfgs_session}{"yo"} = 1;return; }',
    'rule { condition => { class=>"xpto" }, action => { dispatch => 0 } } ok',
  );
};


subtest 'config code' => sub {
  my $c = Logan::Filter::Compiler->new;

  my $one_cfg = [
    { condition => { class    => 'audit' },    action => { dispatch => 'yes' } },
    { condition => { subclass => 'critical' }, action => { dispatch => 'yes' } },
    { action    => { dispatch => 'no' } },
  ];
  my $one_code =
      'sub { my ($e, $s) = @_;'
    . 'my $a1 = $e->{"class"} eq "audit"; if ($a1) { $s->{should_dispatch} = 1;return; }'
    . 'my $a2 = $e->{"subclass"} eq "critical"; if ($a2) { $s->{should_dispatch} = 1;return; }'
    . '{ $s->{should_dispatch} = 0;return; }'
    . ' return ; }';

  my $two_cfg = [
    { condition => { class    => 'zone' },     action => { enable => 'one' } },
    { condition => { subclass => 'critical' }, action => { use    => '$one' } },
    { action    => { dispatch => 'yes' } },
  ];
  my $two_code =
      'sub { my ($e, $s) = @_;'
    . 'my $a1 = $e->{"class"} eq "zone"; if ($a1) { $s->{cfgs_session}{"one"} = 1; }'
    . 'my $a2 = $e->{"subclass"} eq "critical"; if ($a2) { unshift @{$s->{cfgs_to_check}}, "\$one"; }'
    . '{ $s->{should_dispatch} = 1;return; }'
    . ' return ; }';

  is_string($c->_compile_config($one_cfg), $one_code, 'config code looks good');

  cmp_deeply(
    $c->_compile_all_configs({ one => $one_cfg, two => $two_cfg }),
    { one => $one_code,
      two => $two_code,
    },
    'compiling multiple configs also looks very good',
  );
};


subtest 'filter code' => sub {
  my $c = Logan::Filter::Compiler->new;

  my $one_cfg = [
    { condition => { class    => 'audit' },    action => { dispatch => 'yes' } },
    { condition => { subclass => 'critical' }, action => { dispatch => 'yes' } },
    { action    => { dispatch => 'no' } },
  ];
  my $one_code =
      'sub { my ($e, $s) = @_;'
    . 'my $a1 = $e->{"class"} eq "audit"; if ($a1) { $s->{should_dispatch} = 1;return; }'
    . 'my $a2 = $e->{"subclass"} eq "critical"; if ($a2) { $s->{should_dispatch} = 1;return; }'
    . '{ $s->{should_dispatch} = 0;return; }'
    . ' return ; }';

  my $two_cfg = [
    { condition => { class    => 'zone' },     action => { enable => 'one' } },
    { condition => { subclass => 'critical' }, action => { use    => '$one' } },
    { action    => { dispatch => 'yes' } },
  ];
  my $two_code =
      'sub { my ($e, $s) = @_;'
    . 'my $a1 = $e->{"class"} eq "zone"; if ($a1) { $s->{cfgs_session}{"one"} = 1; }'
    . 'my $a2 = $e->{"subclass"} eq "critical"; if ($a2) { unshift @{$s->{cfgs_to_check}}, "\$one"; }'
    . '{ $s->{should_dispatch} = 1;return; }'
    . ' return ; }';

  my $cfg_map = $c->_compile_all_configs({ one => $one_cfg, two => $two_cfg });

  my $filter_defaults = { fallback_config => 'fallback' };
  my $filter_code =
      'do {my %configs = ("one" => '
    . $one_code
    . ',"two" => '
    . $two_code . ',);'
    . 'sub { my ($logan, $session, $event) = @_;'
    . 'my %state = ('
    . ' should_dispatch => undef,'
    . ' cfgs_to_check => [],'
    . ' cfgs_session => $session->stash_for(["Logan::Core::Filters::Exec", "enabled_configs"]),' . ');'
    . ' my $e = $event->{e};'
    . ' my $e_class = $e->{class}; push @{$state{cfgs_to_check}}, $e_class if exists $configs{$e_class};'
    . ' push @{$state{cfgs_to_check}}, "fallback";'
    . ' unshift @{$state{cfgs_to_check}}, keys %{$state{cfgs_session}};'
    . ' while (!defined($state{should_dispatch}) && @{$state{cfgs_to_check}}) {'
    . ' my $cfg = shift @{$state{cfgs_to_check}};'
    . ' next unless exists $configs{$cfg};'
    . ' $configs{$cfg}->($e, \%state);' . '} '
    . ' $state{should_dispatch} = 1 unless defined $state{should_dispatch};'
    . ' return $state{should_dispatch};' . ' }' . '}';

  is_string($c->_emit_filter($filter_defaults, $cfg_map), $filter_code, 'filter code ok');
};


subtest 'filter compilation and execution' => sub {
  my $c = Logan::Filter::Compiler->new;

  my $spec = {
    defaults => { dispatch => 'no' },
    configs  => {
      one => [
        { condition => { class    => 'audit' },    action => { dispatch => 'yes' } },
        { condition => { subclass => 'critical' }, action => { dispatch => 'yes' } },
        { action    => { dispatch => 'no' } },
      ],
      two => [
        { condition => { subclass => 'zone' },     action => { enable => 'one' } },
        { condition => { subclass => 'critical' }, action => { use    => '$one' } },
        { action    => { dispatch => 'yes' } },
      ],
    }
  };

  my $filter_sub = $c->compile($spec);
  is(ref($filter_sub), 'CODE', '::Compiler->compile returns CodeRef');

  my $l = T::Simple::Logan->setup;
  my $s = $l->session;

  ## this is done by the Filter role, but we skip that here, so initialize it ourselfs
  $s->stash_for(["Logan::Core::Filters::Exec", "enabled_configs"], {});

  is($filter_sub->($l, $s, { e => { class => 'audit' } }),
    0, 'running filter code with event that should not dispatch ok');
  is($filter_sub->($l, $s, { e => { class => 'two', subclass => 'zone' } }),
    1, '... this event should be dispatched, and enable the second config');
  is($filter_sub->($l, $s, { e => { class => 'audit' } }), 1, '... and first event now dispatches properly');

  ok($spec->{filter_code}, 'filter spec updated with filter code');
  is($spec->{filter_sub}, $filter_sub, '... and a copy of the filter sub');

  $c = Logan::Filter::Compiler->new(tidy => 1);
  $filter_sub = $c->compile($spec);
  ok($spec->{ugly_filter_code}, 'compiling with tidy => 1 we get the untidy version of the code');
  isnt($spec->{filter_code}, $spec->{ugly_filter_code}, '... which is different from the tidy version');
};


subtest 'private Bool util' => sub {
  my $parse_bool = \&Logan::Filter::Compiler::_parse_bool;

  is($parse_bool->($_), 1, "_parse_bool() sayz '$_' is 1 (true)")  for qw(true 1 yes);
  is($parse_bool->($_), 0, "_parse_bool() sayz '$_' is 0 (false)") for qw(false 0 no);

  is($parse_bool->(undef, default => 'true'), 1, "_parse_bool() accepts hash with 'default' key for undef bool");
};


subtest 'private State class' => sub {
  my $m = Logan::Filter::Compiler::State->new;
  is($m->current_id, 0, 'current_id() starts at zero');
  is($m->next_id,    1, 'next_id() returns the next one');
  is($m->current_id, 1, '... current_id() stays consistent');

  cmp_deeply([$m->atom_id_for('class', 'xpto')], [2, 1], 'new_atom_id_for() generates a new ID...');
  cmp_deeply([$m->atom_id_for('class', 'xpto')], [2], '... but only on first call with the same key');

  cmp_deeply([$m->atom_id_for('class', undef)], [3, 1], 'new_atom_id_for() also supports undef key parts...');
  cmp_deeply([$m->atom_id_for('class', undef)], [3], '... and properly detects duplicate calls even then');
};


done_testing();
