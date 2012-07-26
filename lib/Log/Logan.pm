package Log::Logan;

# ABSTRACT: a very cool module
# VERSION
# AUTHORITY

use Moo;
use Scalar::Util 'blessed';
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


### Logger access
has 'logger_class' => (is => 'ro', builder => 'default_logger_class');
sub default_logger_class {'Log::Logan::Logger'}

sub logger {
  my $self = shift;
  $self = $self->instance unless blessed($self);

  $self->logger_class->new(@_, logan => $self);
}


1;
