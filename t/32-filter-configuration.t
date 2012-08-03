#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Filter::Logan;

my $l = T::Filter::Logan->setup(no_filter_should_dispatch => 1);
my $s = $l->session;

$l->clear_queue;    ## flush any events we might have generated creating the session
my $q = $l->queue;

$s->event({ class => 'audit', subclass => 'fail', msg => 'badboy' });
is(scalar(@$q), 1, 'No filter configured, event was dispatched');

$l->config_update({ filter => { defaults => { dispatch => 'no' } } });
$s->event({ class => 'audit', subclass => 'fail',  msg => 'badboy' });
$s->event({ class => 'log',   subclass => 'debug', msg => 'you are here' });
is(scalar(@$q), 1, 'Filter applied, no more events dispatched');

$l->config_update(
  { filter => {
      defaults => { dispatch => 'no' },
      configs  => { audit    => { rules => [{ action => { dispatch => 'yes' } }] } },
    }
  }
);
$s->event({ class => 'audit', subclass => 'fail',  msg => 'badboy' });
$s->event({ class => 'log',   subclass => 'debug', msg => 'you are here' });
is(scalar(@$q), 2, 'Filter re-configured, one more event dispatched');
cmp_deeply($q->[-1], superhashof({ class => 'audit', msg => 'badboy' }), '... the class audit one');


done_testing();
