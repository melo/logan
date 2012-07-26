#!perl

use Test::More;
use lib 't/tlib';
use MyLogan;

subtest 'per-class singleton with setup override' => sub {
  my $li = MyLogan->instance;
  ok($li,                    'instance() returned something...');
  ok($li->isa('Log::Logan'), '... of the expected type');

  is(MyLogan->instance, $li, 'instance() returns the same object all the time');

  my $ni = MyLogan->setup;
  isnt($ni, $li, 'but setup() forces the creation of a new object...');
  is(MyLogan->instance, $ni, '... and from then on, instance() returns the new object');
};


done_testing;
