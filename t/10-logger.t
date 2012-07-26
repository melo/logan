#!perl

use strict;
use warnings;
use Test::More;
use lib 't/tlib';
use MyLogan;
use MyLogger;


subtest 'logger creation' => sub {
  my $lg = MyLogan->instance;

  my $l1 = $lg->logger;
  ok($l1, 'Got a logger...');
  is(ref($l1), 'Log::Logan::Logger', '... of the expected default Logger class');

  is($l1->logan, $lg, 'logan attr keeps track of the Logan obj that created us');
  like($l1->id, qr{^[a-fA-F0-9-]{36}$}, '... and the id attr looks like a UUID');

  my $l2 = $lg->logger(id => 42);
  is($l2->id, 42, 'attr id can be set when calling Logan->logger()');

  my $l3 = MyLogan->logger;
  is($l3->logan, $l1->logan, 'logger() as class methods uses Logan instance for class');

  my $l4 = MyLogan->logger(logan => 'xpto');
  is($l4->logan, $l1->logan, 'logger() ignores logan attr');

  $lg = MyLogan->setup(logger_class => 'MyLogger');
  ok($lg, 'Change default logger class');
  my $l5 = $lg->logger;
  ok($l5, '... get a new logger...');
  is(ref($l5),   'MyLogger', '... and it is the new Logger class, magic!');
  is($l5->logan, $lg,        '... with the expected new Logan obj');
};


done_testing;
