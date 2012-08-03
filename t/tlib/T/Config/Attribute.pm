package T::Config::Attribute;

use Moo;
extends 'T::Base::Queued';

with 'T::Config::Listener';

sub default_no_filter_should_dispatch {1}

1;
