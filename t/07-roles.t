#!perl

use strict;
use warnings;
use Test::More;
use lib 't/tlib';

subtest 'id UUID' => sub {
  require T::ID::UUID;

  ok(T::ID::UUID->can('generate_id'), 'C::C::R::ID::UUID provides generate_id method');
  like(T::ID::UUID->generate_id, qr{^[a-fA-F0-9-]{36}$}, '... output looks like a UUID');
};


done_testing();
