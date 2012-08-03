package T::Base::Queued;

use Moo;
extends 'Logan';
with 'Logan::Config::Attribute', 'T::Dispatch::Queue';

1;
