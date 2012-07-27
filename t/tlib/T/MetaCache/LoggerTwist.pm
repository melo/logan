package T::MetaCache::LoggerTwist;

use Moo::Role;
use Log::Logan::Utils 'meta_cache_run';
use namespace::autoclean;

before '_event_format' => sub {
  meta_cache_run(
    'twist',
    sub {
      my ($self, $e) = @_;

      $e->{e}{twist_calculated}++;
      $e->{e}{twist} = $$;
    },
    @_
  );
};


1;
