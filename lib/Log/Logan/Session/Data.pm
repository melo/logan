package Log::Logan::Session::Data;

use Moo::Role;
use Carp 'croak';
use namespace::autoclean -also => '_trigger_change_update';

has '_data' => (is => 'rw', init_arg => 'data', default => sub { {} });

sub data {
  my $self = shift;
  my $d    = $self->_data;

  return {%$d} unless @_;
  return { map { exists $d->{$_} ? ($_ => $d->{$_}) : () } @_ };
}

sub set_data {
  my $self = shift;
  return unless @_;

  if (@_ == 1) {
    my $d = $_[0];
    croak "Single parameter call to set_data() must be a HashRef," unless ref($d) eq 'HASH';

    $self->_data({%$d});
  }
  elsif (@_ % 2 == 0) {
    my $d = $self->_data;
    while (my ($k, $v) = splice(@_, 0, 2)) {
      $d->{$k} = $v;
    }
  }
  else {
    croak "set_data() accepts with a Hash or a HashRef: odd-number of params detected,";
  }

  return _trigger_change_update($self);
}

### trigger an event everytime data changes
sub _trigger_change_update {
  my ($self, $subclass) = @_;
  $subclass = 'update' unless $subclass;

  $self->event({ class => 'data', subclass => $subclass, args => $self->data });
  return;
}

sub BUILD { }
after 'BUILD' => sub { _trigger_change_update(shift, 'create') };


1;
