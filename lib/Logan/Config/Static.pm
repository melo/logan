package Logan::Config::Static;

use Moo::Role;
use namespace::autoclean;

has '_cfg' => (is => 'ro', default => sub { {} }, init_arg => 'config');

sub config {
  my $self = shift;
  my $cfg  = $self->_cfg;

  return $cfg unless @_;
  return unless exists $cfg->{ $_[0] };
  return $cfg->{ $_[0] };
}

1;
