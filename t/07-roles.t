#!perl

use Test::More;
use lib 't/tlib';

subtest 'id UUID' => sub {
  require RawIdUUID;

  ok(RawIdUUID->can('generate_id'), 'C::C::R::ID::UUID provides generate_id method');
  like(RawIdUUID->generate_id, qr{^[a-fA-F0-9-]{36}$}, '... output looks like a UUID');
};


done_testing();
