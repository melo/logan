package T::MetaCache::Logger;

use Moo;
extends 'Log::Logan::Logger';
with 'T::MetaCache::LoggerTwist';

1;
