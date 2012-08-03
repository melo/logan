package Logan::Core::Filter;

use Moo::Role;
use namespace::autoclean;


## FIXME: trap config_updated event to trigger a filter recompile


## What to do if there are no rules?
has 'no_filter_should_dispatch' => (is => 'ro', builder => 'default_no_filter_should_dispatch');
sub default_no_filter_should_dispatch {0}


### Filter configuration/compilation
has 'filter' => (
  is      => 'rwp',
  clearer => '1',
  trigger => sub { shift->recompile_filter },
);

has '_filter_sub' => (is => 'rw', clearer => 1);

sub recompile_filter {
  my $self = shift;

  my $filter = $self->filter;
  if (!$filter) {
    $self->_clear_filter_sub;
    return;
  }

  my $sub = eval { Logan::Filter::Compiler->new->compile($filter) };
  if (!$sub) {
    $self->filter_recompile_failed($@);
    return;
  }

  $self->_filter_sub($sub);
  return $sub;
}

sub filter_recompile_failed { print STDERR ref($_[0]) . ": failed to recompile filter - $_[1]\n" }


## The matching process
sub match_rules {
  my ($self, $session, $event) = @_;

  ## Allow per-event override
  return 0 if exists $event->{'m'}{force_discard}  and $event->{'m'}{force_discard};
  return 1 if exists $event->{'m'}{force_dispatch} and $event->{'m'}{force_dispatch};

  ## No filter, no dispatch?
  my $f_sub = $self->_filter_sub;

  return $self->no_filter_should_dispatch unless ref($f_sub) eq 'CODE';

  ## Run the rules gauntlet
  return $f_sub->($self, $session, $event);
}


1;
