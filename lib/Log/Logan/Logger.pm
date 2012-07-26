package Log::Logan::Logger;

# ABSTRACT: the Logger object, represents a logging session
# VERSION
# AUTHORITY

use Moo;

has 'logan' => (is => 'ro', required => 1, weak_ref => 1);
has 'id' => (is => 'lazy');

sub _build_id { shift->logan->generate_id }

1;
