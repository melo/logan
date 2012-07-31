package Logan::Core::Stash;

use Moo::Role;
use namespace::autoclean;


### Stash for session components use
### FIXME: hate the name stash... can't think of a better one right now
has '_stash' => (is => 'ro', default => sub { {} });

sub stash_for {
  my $self  = shift;
  my $stash = $self->_stash;

  my $key = shift;
  $key = join('  --  ', @$key) if ref $key;

  return $stash->{$key} = shift if @_;
  return $stash->{$key} if exists $stash->{$key};
  return;
}

sub stash {
  my $self = shift;
  my $key  = shift;
  my $ns   = caller();

  $key = [$ns, @{ ref $key ? $key : [$key] }];

  return $self->stash_for($key, @_);
}

1;
