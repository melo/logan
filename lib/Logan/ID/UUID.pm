package Logan::ID::UUID;

# ABSTRACT: use UUIDs for Logan::Session IDs
# VERSION
# AUTHORITY

use Moo::Role;
use Carp ();

our $uuid_gen;

BEGIN {
  eval { require Data::UUID };
  if (!$@) {
    my $du = Data::UUID->new;
    $uuid_gen = sub { $du->create_str };
  }
  else {
    eval { require Data::UUID::LibUUID };
    if (!$@) {
      $uuid_gen = sub { Data::UUID::LibUUID::new_uuid_string(4) };
    }
    else {
      Carp::confess("Either Data::UUID (faster on Linux) or Data::UUID::LibUUID (faster on OS X) is required");
    }
  }
}

sub generate_id { return $uuid_gen->() }

1;

__END__

=encoding utf8

=head1 SYNOPSIS

    ## In your app's Logan subclass
    
    package My::App::Logan;
    
    use Moo; ## or use Moose
    extends 'Logan';
    with 'Logan::ID::UUID';
    
    1;

=head1 DESCRIPTION

This role provides the C<< generate_id() >> method that each
L<Logan> subclass needs to provide unique IDs to each
L<Logan::Session> object it creates. It will generate UUIDs (version
3 or version 4, depends on the backend).

At compile time, two UUID generation modules are checked, and the first
one found is used: L<Data::UUID> and L<Data::UUID::LibUUID>. One of
those should be added to your application dependencies.

=head1 METHODS

=head2 generate_id

Returns a new UUID-based identifier.

=cut
