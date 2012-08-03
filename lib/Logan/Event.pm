package Logan::Event;

use Moo;
use namespace::clean;

## TODO: add other roles - callback, category, caller, msg (with formatting), tstamp
## ::Session::* equivalent to here
with 'Logan::Event::Core';

1;
