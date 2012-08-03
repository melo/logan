#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Config::Attribute;

subtest 'access API' => sub {
  my $l = T::Config::Attribute->setup;
  cmp_deeply($l->config, {}, 'config() is empty by default');
  is($l->config('boo'), undef, '... so asking for something that doesnt exist, returns undef');

  $l = T::Config::Attribute->setup(config => { answer => 42 });
  cmp_deeply($l->config, { answer => 42 }, 'config() returns the full config now');
  is($l->config('boo'),    undef, '... but asking for something that doesnt exist, still undef');
  is($l->config('answer'), 42,    'asking for something that is there returns the expected value');
};


subtest 'config updates' => sub {
  my $l = T::Config::Attribute->setup;
  cmp_deeply($l->config, {}, 'config() is empty by default');
  is($l->update_called, 0, 'our update signal defaults to down');

  $l->config_update();
  is($l->update_called, 0, 'after config_update() call without arguments, no change');

  $l->config_update([]);
  is($l->update_called, 0, 'after config_update() call with ArrayRef, no change');

  $l->config_update({ answer => 42 });
  is($l->update_called, 1, 'config_update() called with HashRef, update was signalled');
  cmp_deeply($l->config, { answer => 42 }, '... and new config is solid');
};


done_testing();
