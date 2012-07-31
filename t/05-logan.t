#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Simple::Logan;

subtest 'per-class $lg->stash with setup override' => sub {
  my $li = T::Simple::Logan->instance;
  ok($li,               'instance() returned something...');
  ok($li->isa('Logan'), '... of the expected type');

  is(T::Simple::Logan->instance, $li, 'instance() returns the same object all the time');

  my $ni = T::Simple::Logan->setup;
  isnt($ni, $li, 'but setup() forces the creation of a new object...');
  is(T::Simple::Logan->instance, $ni, '... and from then on, instance() returns the new object');
};


subtest 'stash_for, simple keys' => sub {
  my $lg = T::Simple::Logan->setup;
  my $my = 'my';

  is($lg->stash_for($my), undef, 'no stash_for defined at start');

  my $precious = { answer => 42, author => 'dna' };
  is($lg->stash_for($my, $precious), $precious, 'stash_for() returns value set');

  is($lg->stash_for($my), $precious, 'value set properly as expected');

  $lg = T::Simple::Logan->setup;
  is($lg->stash_for($my), undef, 'stash_for is per-Logan instance, so new instance, fresh stash');
};


subtest 'stash_for, multi-part keys' => sub {
  my $lg  = T::Simple::Logan->setup;
  my $ref = {};
  my $my  = ['my', $ref];

  is($lg->stash_for($my), undef, 'no stash_for defined at start');

  my $precious = { answer => 42, author => 'dna' };
  is($lg->stash_for($my, $precious), $precious, 'stash_for() returns value set');

  is($lg->stash_for($my), $precious, 'value set properly as expected');
};


subtest 'stash, simple keys' => sub {
  my $lg       = T::Simple::Logan->setup;
  my $my       = 'my';
  my $precious = { answer => 42, author => 'dna' };

  {

    package StashFirstNS;
    my $val = { p => $precious, ns => 'First' };
    main::is($lg->stash($my), undef, 'no stash defined at start for StashFirstNS');
    main::is($lg->stash($my, $val), $val, '... stash() returns value set');
    main::is($lg->stash($my), $val, '... value set properly as expected');
  }

  {

    package StashSecondNS;
    my $val = { p => $precious, ns => 'Second' };
    main::is($lg->stash($my), undef, 'no stash defined at start for StashSecondNS');
    main::is($lg->stash($my, $val), $val, '... stash() returns value set');
    main::is($lg->stash($my), $val, '... value set properly as expected');
  }

  cmp_deeply($lg->stash_for(['StashFirstNS', $my]), { p => $precious, ns => 'First' }, 'stash_for() ns => caller pckg');
  cmp_deeply($lg->stash_for(['StashSecondNS', $my]), { p => $precious, ns => 'Second' }, '... confirmed for SecondNS');
};


subtest 'stash, multi-part keys' => sub {
  my $lg       = T::Simple::Logan->setup;
  my $ref      = {};
  my $my       = ['my', $ref];
  my $precious = { answer => 42, author => 'dna' };

  {

    package StashNS;
    main::is($lg->stash($my), undef, 'no stash defined at start');
    main::is($lg->stash($my, $precious), $precious, 'stash() returns value set');
    main::is($lg->stash($my), $precious, 'value set properly as expected');
  }

  is($lg->stash_for(['StashNS', @$my]), $precious, 'stash_ns() is based on stash() using caller pckg as namespace');
};


done_testing;
