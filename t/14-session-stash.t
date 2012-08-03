#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Simple::Logan;


subtest 'stash_for, simple keys' => sub {
  my $s  = T::Simple::Logan->setup->session;
  my $my = 'my';

  is($s->stash_for($my), undef, 'no stash_for defined at start');

  my $precious = { answer => 42, author => 'dna' };
  is($s->stash_for($my, $precious), $precious, 'stash_for() returns value set');

  is($s->stash_for($my), $precious, 'value set properly as expected');

  $s = T::Simple::Logan->setup->session;
  is($s->stash_for($my), undef, 'stash_for is per-Logan instance, so new instance, fresh stash');
};


subtest 'stash_for, multi-part keys' => sub {
  my $s   = T::Simple::Logan->setup->session;
  my $ref = {};
  my $my  = ['my', $ref];

  is($s->stash_for($my), undef, 'no stash_for defined at start');

  my $precious = { answer => 42, author => 'dna' };
  is($s->stash_for($my, $precious), $precious, 'stash_for() returns value set');

  is($s->stash_for($my), $precious, 'value set properly as expected');
};


subtest 'stash, simple keys' => sub {
  my $s        = T::Simple::Logan->setup->session;
  my $my       = 'my';
  my $precious = { answer => 42, author => 'dna' };

  {

    package StashFirstNS;
    my $val = { p => $precious, ns => 'First' };
    main::is($s->stash($my), undef, 'no stash defined at start for StashFirstNS');
    main::is($s->stash($my, $val), $val, '... stash() returns value set');
    main::is($s->stash($my), $val, '... value set properly as expected');
  }

  {

    package StashSecondNS;
    my $val = { p => $precious, ns => 'Second' };
    main::is($s->stash($my), undef, 'no stash defined at start for StashSecondNS');
    main::is($s->stash($my, $val), $val, '... stash() returns value set');
    main::is($s->stash($my), $val, '... value set properly as expected');
  }

  cmp_deeply($s->stash_for(['StashFirstNS', $my]), { p => $precious, ns => 'First' }, 'stash_for() ns => caller pckg');
  cmp_deeply($s->stash_for(['StashSecondNS', $my]), { p => $precious, ns => 'Second' }, '... confirmed for SecondNS');
};


subtest 'stash, multi-part keys' => sub {
  my $s        = T::Simple::Logan->setup->session;
  my $ref      = {};
  my $my       = ['my', $ref];
  my $precious = { answer => 42, author => 'dna' };

  {

    package StashNS;
    main::is($s->stash($my), undef, 'no stash defined at start');
    main::is($s->stash($my, $precious), $precious, 'stash() returns value set');
    main::is($s->stash($my), $precious, 'value set properly as expected');
  }

  is($s->stash_for(['StashNS', @$my]), $precious, 'stash_ns() is based on stash() using caller pckg as namespace');
};


done_testing();
