package T::MetaCache::Logan;

use Moo;
use T::MetaCache::Logger;

extends 'T::Logan::Queued';

sub default_session_class { 'T::MetaCache::Logger' }

1;
