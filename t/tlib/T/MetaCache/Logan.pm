package T::MetaCache::Logan;

use Moo;
use T::MetaCache::Logger;

extends 'Log::Logan';
with 'Log::Logan::ID::UUID', 'T::Dispatch::Queue';

sub default_session_class { 'T::MetaCache::Logger' }

1;
