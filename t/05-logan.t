#!perl

use strict;
use warnings;
use Test::More;
use lib 't/tlib';
use T::Simple::Logan;

subtest 'per-class singleton with setup override' => sub {
  my $li = T::Simple::Logan->instance;
  ok($li,                    'instance() returned something...');
  ok($li->isa('Log::Logan'), '... of the expected type');

  is(T::Simple::Logan->instance, $li, 'instance() returns the same object all the time');

  my $ni = T::Simple::Logan->setup;
  isnt($ni, $li, 'but setup() forces the creation of a new object...');
  is(T::Simple::Logan->instance, $ni, '... and from then on, instance() returns the new object');
};


done_testing;
