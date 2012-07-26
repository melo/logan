#!perl

use Test::More;
use lib 't/tlib';
use MyLogger;

subtest 'per-class singleton with setup override' => sub {
  my $li = MyLogger->instance;
  ok($li,                    'instance() returned something...');
  ok($li->isa('Log::Logan'), '... of the expected type');

  is(MyLogger->instance, $li, 'instance() returns the same object all the time');

  my $ni = MyLogger->setup;
  isnt($ni, $li, 'but setup() forces the creation of a new object...');
  is(MyLogger->instance, $ni, '... and from then on, instance() returns the new object');
};


done_testing;
