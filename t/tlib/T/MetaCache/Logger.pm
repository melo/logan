package T::MetaCache::Logger;

use Moo;
extends 'Log::Logan::Session';
with 'T::MetaCache::LoggerTwist';

1;
