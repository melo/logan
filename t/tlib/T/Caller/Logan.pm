package T::Caller::Logan;

use Moo;
extends 'Log::Logan';
with 'T::Dispatch::Queue';

BEGIN {
  my $has_try_tiny = eval { require Try::Tiny };
  Try::Tiny->import if $has_try_tiny;

  sub has_try_tiny {$has_try_tiny}
}


sub simple_caller_test {
  my $l = shift->session;

  $l->event({ class => 'c', subclass => 'cs', msg => 'msg' });
}

sub eval_caller_test {
  my $l = shift->session;

  eval { $l->event({ class => 'c', subclass => 'cs', msg => 'msg' }) };
}

sub try_tiny_caller_test {
  return unless has_try_tiny();

  my $l = shift->session;

  try { $l->event({ class => 'c', subclass => 'cs', msg => 'msg' }) };
}

sub complex_caller_test {
  return unless has_try_tiny();

  my $l = shift->session;

  eval {
    try {
      eval { $l->event({ class => 'c', subclass => 'cs', msg => 'msg' }) };
    }
  };
}

1;
