package Logan::Event::Core;

use Moo::Role;
use namespace::clean;

has 'session' => (is => 'ro', weak_ref => 1, required => 1);

has 'data' => (is => 'ro', default => sub { {} });

has '_meta' => (is => 'ro', default => sub { {} }, _init_arg => 'meta');

sub meta {
  my $self = shift;
  my $meta = $self->_meta;

  ## All of meta
  return $meta unless @_;

  ## Set
  return $meta->{ $_[0] } = $_[1] if @_ == 2;

  ## Get, no autovivification
  return unless exists $meta->{ $_[0] };
  return $meta->{ $_[0] };
}

1;
