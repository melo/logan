package Log::Logan::Logger::Caller;

use Moo::Role;
use Log::Logan::Utils 'meta_cache_run';
use namespace::autoclean;

## Our hook point
requires '_event_format';


## Configuration: override on your App::Logan::Logger to tweak
sub caller_ignore_frame { shift->caller_default_ignore_frame(@_) }

sub should_caller_find_method_name {1}


## Reusable good defaults
sub caller_default_ignore_frame {
  my ($self, $c, $m) = @_;

  return 1 if $c =~ m/^Log::Logan:?/;
  return 1 if $c =~ m/^Try::Tiny:?/;
  return 1 if $m eq '(eval)';
  return 1 if $m eq '__ANON__';

  return;
}


## The real work is done here
before '_event_format' => sub {
  meta_cache_run(
    caller => sub {
      my ($self, $e) = @_;

      my $icf = $e->{'m'}{'caller'};

      $e->{e}{caller} = {
        class => $icf->[0],
        file  => $icf->[1],
        line  => $icf->[2],
      };

      $self->_caller_find_method_name($e) if $self->should_caller_find_method_name;
    },
    @_
  );

  meta_cache_run(
    category => sub {
      my ($self, $e) = @_;

      my $ci = $e->{e}{caller};
      my $c  = $ci->{class};
      my $m  = exists $ci->{method} ? $ci->{method} : '';
      $c =~ s/([a-z])([A-Z])/${1}_${2}/g;
      $c =~ s/::/./g;
      $m =~ s/^_+//g;
      $e->{e}{category} = lc(join('.', grep {$_} ($c, $m)));
    },
    @_
  );
};

sub _caller_find_method_name {
  my ($self, $e) = @_;
  my $ev = $e->{e};

  my ($frame, $tc) = $self->_find_start_frame($e);
  return unless $frame;

  my $ci;
  while ($frame < 20) {
    my ($c, $m) = (caller(++$frame))[0, 3];
    last unless $c && $m;

    next unless $m =~ /(.+)::(.+)/;
    ($c, $m) = ($1, $2);

    next if $c ne $tc;    ## Look only at frames that match our target class
    next if $self->caller_ignore_frame($c, $m);

    $ev->{caller}{method} = $m;
    last;
  }
}

sub _find_start_frame {
  my ($self, $e) = @_;
  my $icf = $e->{e}{caller};
  my ($f, $l) = ($icf->{file}, $icf->{line});

  my $frame = 0;
  while (1) {
    my ($c, $m, $ff, $fl) = (caller(++$frame))[0, 3, 1, 2];
    $frame = undef, last unless defined $ff;
    last if $ff eq $f && $fl == $l;
  }

  return ($frame - 1, $icf->{class});    ## remove 1 to account for us
}


1;
