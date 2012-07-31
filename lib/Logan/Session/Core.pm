package Logan::Session::Core;

use Moo::Role;
use namespace::autoclean;

has 'logan' => (is => 'ro', required => 1, weak_ref => 1);
has 'id' => (is => 'lazy');

sub _build_id { shift->logan->generate_id }

sub event {
  my $self = shift;
  my $e    = $self->_parse_event_builder_args(@_);

  return $self->process($e);
}

sub process {
  my ($self, $e) = @_;

  $self->_event_format($e);

  return $self->logan->process($e);
}

sub _event_format { }

sub _parse_event_builder_args {
  my $self = shift;
  my ($caller, $file, $line, $api) = my @cf = (caller(1))[0 .. 3];

  my ($e, $m);
  if (@_ == 1) { $e = $_[0] }
  elsif (@_ == 2 && ref $_[0]) { ($e, $m) = @_ }
  elsif (@_ % 2 == 0) { $e = {@_} }
  else                { die "Bad call to $api: could not parse arguments, $file at $line\n" }

  $m = {} unless ref $m;
  $m->{caller} = \@cf;

  $e->{msg}  = '' unless defined $e->{msg};
  $e->{args} = {} unless ref $e->{args};

  return { e => $e, m => $m };
}


1;
