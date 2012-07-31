package Logan::Core::EventProcessing;

use Moo::Role;
use namespace::autoclean;

sub process {
  my ($self, $event) = @_;

  ## FIXME: add filter checks
  ## FIXME: make sure all enrichment callbacks are executed

  ## FIXME: return $self->dispatch - allow return code to mean something
  $self->dispatch($event->{e}, $event->{m});

  return 1;
}

1;
