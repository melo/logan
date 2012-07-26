package Log::Logan::Logger;

# ABSTRACT: the Logger object, represents a logging session
# VERSION
# AUTHORITY

use Moo;

has 'logan' => (is => 'ro', required => 1, weak_ref => 1);
has 'id' => (is => 'lazy');

sub _build_id { shift->logan->generate_id }

sub event {
  my ($self, $class, $subclass, $msg, $user_data) = @_;
  $msg       = '' unless defined $msg;
  $user_data = {} unless ref $user_data;

  my $event = {
    class    => $class,
    subclass => $subclass,
    msg      => $msg,
    data     => $user_data,
  };

  return $self->logan->process($event);
}

1;
