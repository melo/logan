package Logan::Config::Static;

use Moo::Role;
use namespace::autoclean;

requires 'signal_config_updated';

has '_cfg' => (is => 'rw', default => sub { {} }, init_arg => 'config');

sub config {
  my $self = shift;
  my $cfg  = $self->_cfg;

  return $cfg unless @_;
  return unless exists $cfg->{ $_[0] };
  return $cfg->{ $_[0] };
}

sub config_update {
  my ($self, $new_cfg) = @_;
  return unless $new_cfg && ref($new_cfg) eq 'HASH';

  $self->_cfg($new_cfg);
  $self->signal_config_updated();

  return;
}

1;
