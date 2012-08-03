package Logan::Core::EventProcessing;

use Moo::Role;
use namespace::autoclean;

#requires 'match_rules', 'dispatch';
requires 'match_rules';

sub process {
  my ($self, $session, $event) = @_;

  ## return unless $self->match_rules($session, $event);
  use Data::Dump qw(pp);
  push @{ $event->{m}{log} }, "## filter event ", pp($event);
  my $matched = $self->match_rules($session, $event);
  push @{ $event->{m}{log} }, "## matched result is $matched";
  return unless $matched;
  push @{ $event->{m}{log} }, "## dispatching...";

  ## FIXME: make sure all enrichment callbacks are executed

  ## FIXME: return $self->dispatch - allow return code to mean something
  ## FIXME: use $session, $event - consistent with other APIs
  ## FIXME: use only $event if $event is converted to a object with a weak_ref to $session
  $self->dispatch($event->{e}, $event->{m}, $session);

  return 1;
}

1;
