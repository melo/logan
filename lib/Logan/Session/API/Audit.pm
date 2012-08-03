package Logan::Session::API::Audit;

use Moo::Role;
use Sub::Name;
use namespace::autoclean;

BEGIN {
  no strict 'refs';
  my $p = __PACKAGE__ . '::';

  for my $evn (qw( authorized denied create delete updated )) {
    my $m = "$p$evn";
    *{$m} = subname $m, sub {
      $_[0]->process(
        $_[0]->_parse_event_builder_args(
          msg      => $_[1],
          args     => $_[2],
          class    => 'audit',
          subclass => $evn,
        )
      );
    };
  }
}


1;
