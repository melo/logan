package Logan::Session::Logger;

use Moo::Role;
use Sub::Name;
use namespace::autoclean;

BEGIN {
  no strict 'refs';
  my $p = __PACKAGE__ . '::';

  for my $sev (qw( trace debug info warn error critical fatal )) {
    my $m = "$p$sev";
    *{$m} = subname $m, sub {
      $_[0]->process(
        $_[0]->_parse_event_builder_args(
          msg      => $_[1],
          args     => $_[2],
          class    => 'logger',
          subclass => $sev,
        )
      );
    };
  }
}


1;
