package T::Config::Listener;

use Moo::Role;
use namespace::clean;

has 'update_called' => (is => 'rwp', clearer => 1, default => sub {0});

after 'signal_config_updated' => sub {
  shift->_set_update_called(1);
};

1;
