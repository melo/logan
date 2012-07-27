package T::MetaCache::Logan;

use Moo;
use T::MetaCache::Logger;

extends 'Log::Logan';
with 'Log::Logan::ID::UUID', 'MySimpleDispatchQueue';

sub default_logger_class { 'T::MetaCache::Logger' }

1;
