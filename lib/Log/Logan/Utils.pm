package Log::Logan::Utils;

use strict;
use warnings;
use parent 'Exporter';

our @EXPORT_OK = qw( meta_cache_run );

sub meta_cache_run {
  my ($key, $cb, $session, $e) = @_;
  my $logan = $session->logan;

  ## Never override event info
  return if exists $e->{e}{$key};

  ## no meta_cache enabled? skip
  return $cb->($session, $e) unless $logan && $logan->can('use_meta_cache') && $logan->use_meta_cache;

  ## use cache if available
  return if defined $logan->meta_cache_fill($e, $key);

  ## calculate value and cache it if possible
  $cb->($session, $e);
  $logan->meta_cache_add($e, $key);

  return;
}

1;
