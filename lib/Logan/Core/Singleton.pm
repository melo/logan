package Logan::Core::Singleton;

use Moo::Role;
use namespace::autoclean;

our %instances;

sub instance {
  my $class = shift;
  return $instances{$class} || $class->setup(@_);
}

sub setup {
  my $class = shift;

  return $instances{$class} = $class->new(@_);
}

1;
