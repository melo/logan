#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use lib 't/tlib';
use T::Config::Static;

my $l = T::Config::Static->setup;
cmp_deeply($l->config, {}, 'config() is empty by default');
is($l->config('boo'), undef, '... so asking for something that doesnt exist, returns undef');

$l = T::Config::Static->setup(config => { answer => 42 });
cmp_deeply($l->config, { answer => 42 }, 'config() returns the full config now');
is($l->config('boo'),    undef, '... but asking for something that doesnt exist, still undef');
is($l->config('answer'), 42,    'asking for something that is there returns the expected value');


done_testing();
