package T::Dispatch::Queue;

use Moo::Role;

has 'queue' => (is => 'lazy', clearer => 1);
sub _build_queue { [] }

sub queue_message { push @{ shift->queue }, shift }
sub dispatch { shift->queue_message(@_) }

1;

