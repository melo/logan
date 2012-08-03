package T::Config::Static;

use Moo;
extends 'T::Logan::Queued';
with 'Logan::Config::Static';

sub default_no_filter_should_dispatch {1}

1;
