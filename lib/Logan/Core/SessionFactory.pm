package Logan::Core::SessionFactory;

use Moo::Role;
use Scalar::Util 'blessed';
use namespace::autoclean;

has 'session_class' => (is => 'ro', builder => 'default_session_class');
sub default_session_class {'Logan::Session'}

sub session {
  my $self = shift;
  $self = $self->instance unless blessed($self);

  $self->session_class->new(@_, logan => $self);
}

1;
