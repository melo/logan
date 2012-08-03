package T::MetaCache::Logan;

use Moo;
use T::MetaCache::Logger;

extends 'T::Base::Queued';

sub default_no_filter_should_dispatch {1}
sub default_session_class             {'T::MetaCache::Logger'}

1;
