package Log::Logan::Core;

use Moo::Role;
use Scalar::Util 'blessed';
use Log::Logan::Session;
use namespace::autoclean;


### Per-class singleton management
{
  our %instances;

  sub instance {
    my $class = shift;
    return $instances{$class} || $class->setup(@_);
  }

  sub setup {
    my $class = shift;

    return $instances{$class} = $class->new(@_);
  }
}


### Session access
has 'session_class' => (is => 'ro', builder => 'default_session_class');
sub default_session_class {'Log::Logan::Session'}

sub session {
  my $self = shift;
  $self = $self->instance unless blessed($self);

  $self->session_class->new(@_, logan => $self);
}


### Event dispatching
sub process {
  my ($self, $event) = @_;

  $self->dispatch($event->{e}, $event->{m});

  return 1;
}


### Stash for session components use
### FIXME: hate the name stash... can't think of a better one right now
has '_stash' => (is => 'ro', default => sub { {} });
sub stash {
  my $self = shift;
  my $key = shift;
  $key = join('  --  ', @$key) if ref $key;

  my $stash = $self->_stash;
  return $stash->{$key} = shift if @_;
  return $stash->{$key} if exists $stash->{$key};
  return;
}


1;
