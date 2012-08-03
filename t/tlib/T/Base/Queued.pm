package T::Base::Queued;

use Moo;
extends 'Logan';
with 'Logan::Config::Attribute', 'T::Dispatch::Queue';

sub default_no_filter_should_dispatch {1}

1;
