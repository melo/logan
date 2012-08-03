package Logan::Core;

use Moo::Role;
use Logan::Session;
use namespace::autoclean;

with
  'Logan::Core::Config',
  'Logan::Core::Singleton',
  'Logan::Core::SessionFactory',
  'Logan::Core::Filter',
  'Logan::Core::Processing',
  'Logan::Core::Stash';


1;
