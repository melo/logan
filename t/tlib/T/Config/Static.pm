package T::Config::Static;

use Moo;
extends 'T::Base::Queued';

sub default_no_filter_should_dispatch {1}

1;
