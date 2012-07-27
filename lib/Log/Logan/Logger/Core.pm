package Log::Logan::Logger::Core;

use Moo::Role;

has 'logan' => (is => 'ro', required => 1, weak_ref => 1);
has 'id' => (is => 'lazy');

sub _build_id { shift->logan->generate_id }

sub event {
  my ($self, $e, $m) = @_;
  $m = $self->new_meta unless $m;

  $e->{msg}  = '' unless defined $e->{msg};
  $e->{data} = {} unless ref $e->{data};

  $e = {
    e => $e,
    m => $m,
  };

  $self->_event_format($e);

  return $self->logan->process($e);
}

sub _event_format { }

sub new_meta { return { caller => [(caller(1))[0 .. 3]] } }

1;
