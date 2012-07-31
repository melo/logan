package Logan::MetaCache;

use Moo::Role;

has 'meta_cache' => (is => 'ro', default => sub { {} });

sub use_meta_cache {1}

sub meta_cache_add {
  my ($self, $e, @keys) = @_;
  my $cache = $self->meta_cache_for($e);
  return unless $cache;

  $e = $e->{e};
  for my $k (@keys) {
    next unless exists $e->{$k} && defined $e->{$k};
    $cache->{$k} = $e->{$k};
  }
}

sub meta_cache_for {
  my ($self, $e) = @_;
  my $icf = $e->{'m'}{'caller'};
  return unless $icf;

  my $cache_key = "$icf->[1]:$icf->[2]";
  return $self->meta_cache->{$cache_key} ||= {};
}

sub meta_cache_fill {
  my ($self, $e, $key) = @_;
  return if exists $e->{e}{$key};    ## cache will not override info already present

  my $cache = $self->meta_cache_for($e);
  return unless $cache && exists $cache->{$key};

  return $e->{e}{$key} = $cache->{$key};
}

1;
