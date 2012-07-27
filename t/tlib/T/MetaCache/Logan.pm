package T::MetaCache::Logan;

use Moo;
use T::MetaCache::Logger;

extends 'Log::Logan';
with 'T::Dispatch::Queue';

sub default_session_class { 'T::MetaCache::Logger' }

1;
