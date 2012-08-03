package T::Base::Queued;

use Moo;
extends 'Logan';
with 'Logan::Config::Static', 'T::Dispatch::Queue';

1;
