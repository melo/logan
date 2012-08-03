#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Filter::Logan;


run_all_use_cases(
  use_case(
    descr('default logan and session settings, no filter'),
    events(
      e(0, 'a', 'b', 'default_no_filter_should_dispatch used'),
      em(1, 'a', 'b', { force_dispatch => 1 }, 'force_dispatch => 1 used'),
    )
  ),
  use_case(
    descr('logan no_filter_should_dispatch => 1, no filter'),
    logan(no_filter_should_dispatch => 1),
    events(
      e(1, 'a', 'b', 'default_no_filter_should_dispatch used'),
      em(1, 'a', 'b', { force_dispatch => 1 }, 'force_dispatch => 1 used'),
      em(1, 'a', 'b', { force_dispatch => 0 }, 'force_dispatch => 0 used'),
      em(1, 'a', 'b', { force_discard  => 0 }, 'force_discard => 0 used => no_filter_should_dispatch wins'),
      em(0, 'a', 'b', { force_discard  => 1 }, 'force_discard => 1 used'),
    )
  ),
);


done_testing();

#############
# Test runner


sub run_all_use_cases {
  for my $s_tc (@_) {
    my ($f_spec, $l_spec, $s_spec, $descr, $events) = @{$s_tc}{qw(filter logan session descr events)};
    ok(($descr && $events), "use case: $descr");

    $l_spec = [] unless ref($l_spec);
    push @$l_spec, filter => $f_spec if $f_spec;

    my $l = T::Filter::Logan->setup(@$l_spec);
    my $s = $l->session(@{ $s_spec || [] });

    for my $ev_tc (@$events) {
      my ($edescr, $e_spec, $m_spec, $expected_count) = @{$ev_tc}{qw(descr event meta count)};

      $l->clear_queue;
      $s->event($e_spec, $m_spec);
      my $dispatched_count = @{ $l->queue };
      my $success =
        is($dispatched_count, $expected_count,
        " ... $edescr ok, " . ($expected_count ? 'sent' : 'skipped') . " ($dispatched_count == $expected_count)");

      if ($expected_count != $dispatched_count) {
        use Data::Dump qw(pp);
        my $log = delete $m_spec->{log} || [];
        print STDERR ">>>>>> failed $edescr\n";
        print STDERR "$_\n" for @$log;
        print STDERR ">>>>>> final ev/meta: " . pp($e_spec, $m_spec), "\n";
      }
    }
  }
}

#############################################
# Tiny DSL to make filter config setup easier

sub use_case { return {@_} }
sub events { return (events => [@_]) }

sub e {
  splice(@_, -1, 0, {});
  goto \&em;
}

sub em {
  my $d    = pop @_;
  my $meta = pop @_;
  my ($cnt, $c, $sc, $msg, $args) = @_;

  return {
    descr => $d,
    count => $cnt,
    event => { class => $c, subclass => $sc, msg => $msg, args => $args },
    meta  => $meta,
  };
}

sub descr   { return (descr   => shift) }
sub logan   { return (logan   => [@_]) }
sub session { return (session => [@_]) }

sub l_trace    { return event('log', 'trace',    @_) }
sub l_debug    { return event('log', 'debug',    @_) }
sub l_info     { return event('log', 'info',     @_) }
sub l_error    { return event('log', 'error',    @_) }
sub l_fatal    { return event('log', 'fatal',    @_) }
sub l_critical { return event('log', 'critical', @_) }

