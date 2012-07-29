#!perl

use strict;
use warnings;
use Test::More;
use lib 't/tlib';
use T::Simple::Logan;

subtest 'per-class $lg->stash with setup override' => sub {
  my $li = T::Simple::Logan->instance;
  ok($li,                    'instance() returned something...');
  ok($li->isa('Log::Logan'), '... of the expected type');

  is(T::Simple::Logan->instance, $li, 'instance() returns the same object all the time');

  my $ni = T::Simple::Logan->setup;
  isnt($ni, $li, 'but setup() forces the creation of a new object...');
  is(T::Simple::Logan->instance, $ni, '... and from then on, instance() returns the new object');
};


subtest 'stash, simple keys' => sub {
  my $lg = T::Simple::Logan->setup;
  my $my = 'my';

  is($lg->stash($my), undef, 'no stash defined at start');

  my $precious = { answer => 42, author => 'dna' };
  is($lg->stash($my, $precious), $precious, 'stash() returns value set');

  is($lg->stash($my), $precious, 'value set properly as expected');

  $lg = T::Simple::Logan->setup;
  is($lg->stash($my), undef, 'stash is per-Logan instance, so new instance, fresh stash');
};


subtest 'stash, multi-part keys' => sub {
  my $lg  = T::Simple::Logan->setup;
  my $ref = {};
  my $my  = ['my', $ref];

  is($lg->stash($my), undef, 'no stash defined at start');

  my $precious = { answer => 42, author => 'dna' };
  is($lg->stash($my, $precious), $precious, 'stash() returns value set');

  is($lg->stash($my), $precious, 'value set properly as expected');
};


done_testing;
