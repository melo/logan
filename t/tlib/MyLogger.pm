package MyLogger;

use Moo;
extends 'Log::Logan::Logger';

has 'woo' => (is => 'ro');

1;
