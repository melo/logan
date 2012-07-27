package Log::Logan::Session::MessageFmt;

use Moo::Role;
use Data::Dump ();
use namespace::autoclean;

requires '_event_format';

before '_event_format' => sub {
  my ($self, $e) = @_;
  my $d = $e->{e}{data};

  $e->{e}{msg} =~ s/#{(.+?)}/$self->_fmt_value_for($d, $1)/ge;
};

sub _fmt_value_for {
  my ($self, $d, $k) = @_;
  die "Event message has '$k' field, but no such field found on user data," unless exists $d->{$k};

  my $v = $d->{$k};
  return $self->message_undef_fmt unless defined $v;
  return ref $v ? $self->message_ref_fmt($v) : $v;
}

sub message_undef_fmt {'<undef>'}
sub message_ref_fmt   { Data::Dump::pp($_[1]) }

1;
