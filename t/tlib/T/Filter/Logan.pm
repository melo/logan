package T::Filter::Logan;

use Moo;
extends 'T::Base::Queued';

sub default_no_filter_should_dispatch {0}

1;
