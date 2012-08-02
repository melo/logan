package T::Simple::Logan;

use Moo;
extends 'T::Logan::Queued';

sub default_no_filter_should_dispatch {1}

1;
