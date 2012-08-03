package Logan::Core::Config;

use Moo::Role;
use namespace::autoclean;

# requires 'config', 'config_update';
sub signal_config_updated { }

1;
