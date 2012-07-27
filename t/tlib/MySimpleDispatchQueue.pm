package MySimpleDispatchQueue;

use Moo::Role;

has 'queue' => (is => 'ro', default => sub { [] }, clearer => 1);

sub queue_message { push @{ shift->queue }, shift }
sub dispatch { shift->queue_message(@_) }

1;

