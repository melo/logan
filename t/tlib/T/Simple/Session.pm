package T::Simple::Session;

use Moo;
extends 'Log::Logan::Session';

has 'woo' => (is => 'ro');

1;
