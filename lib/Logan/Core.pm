package Logan::Core;

use Moo::Role;
use Logan::Session;
use namespace::autoclean;

with 'Logan::Core::Singleton',
  'Logan::Core::SessionFactory',
  'Logan::Core::Filter',
  'Logan::Core::EventProcessing',
  'Logan::Core::Stash';


1;
