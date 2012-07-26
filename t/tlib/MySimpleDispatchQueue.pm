package MySimpleDispatchQueue;

use Moo::Role;

has 'queue' => (is => 'ro', default => sub { [] }, clearer => 1);

sub queue_message { push @{ shift->queue }, shift }

1;

