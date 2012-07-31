package Logan::Session::TStamp;

use Moo::Role;
use Time::HiRes 'gettimeofday';
use namespace::autoclean;

requires '_event_format';

before '_event_format' => sub {
  my ($self, $e) = @_;
  $e->{e}{tstamp} = [gettimeofday()];
};

1;
