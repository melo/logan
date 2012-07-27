package MyLoganForCaller;

use Moo;
extends 'Log::Logan';
with 'Log::Logan::ID::UUID', 'MySimpleDispatchQueue';

BEGIN {
  my $has_try_tiny = eval { require Try::Tiny };
  Try::Tiny->import if $has_try_tiny;

  sub has_try_tiny {$has_try_tiny}
}


sub simple_caller_test {
  my $l = shift->logger;

  $l->event({ class => 'c', subclass => 'cs', msg => 'msg' });
}

sub eval_caller_test {
  my $l = shift->logger;

  eval { $l->event({ class => 'c', subclass => 'cs', msg => 'msg' }) };
}

sub try_tiny_caller_test {
  return unless has_try_tiny();

  my $l = shift->logger;

  try { $l->event({ class => 'c', subclass => 'cs', msg => 'msg' }) };
}

sub complex_caller_test {
  return unless has_try_tiny();

  my $l = shift->logger;

  eval {
    try {
      eval { $l->event({ class => 'c', subclass => 'cs', msg => 'msg' }) };
    }
  };
}

1;
