package Logan::Filter::Compiler;

use Moo;
use namespace::autoclean;

has 'tidy' => (is => 'ro');

sub compile {
  my ($self, $spec) = @_;

  my $configs = $self->_compile_all_configs($spec->{configs});
  my $filter_code = $self->_emit_filter($spec->{defaults}, $configs);
  $spec->{filter_code} = $filter_code;

  if ($self->{tidy}) {
    require Perl::Tidy;
    my $tidy_filter_code;
    Perl::Tidy::perltidy(source => \$filter_code, destination => \$tidy_filter_code);
    $spec->{ugly_filter_code} = $filter_code;
    $filter_code = $spec->{filter_code} = $tidy_filter_code;
  }

  my $filter = eval $filter_code;
  die "Failed to compile filter: $@" if $@;

  return $spec->{filter_sub} = $filter;
}

sub _emit_filter {
  my ($self, $defaults, $configs) = @_;

  return
      'do { package Logan::Core::Filters::Compiled;'
    . $self->_emit_filter_configs_decl($configs)
    . 'sub { my ($logan, $session, $event) = @_;'
    . 'my %state = ('
    . ' should_dispatch => undef,'
    . ' cfgs_to_check => [],' . ');'
    . ' if (my $cfgs_session = $session->stash("enabled_configs"))'
    . ' { $state{cfgs_session} = $cfgs_session }'
    . ' else { $session->stash("enabled_configs", $state{cfgs_session} = {}) }'
    . ' my $e = $event->{e};'
    . $self->_emit_filter_config_per_class_def($defaults)
    . $self->_emit_filter_fallback_config_def($defaults)
    . ' unshift @{$state{cfgs_to_check}}, keys %{$state{cfgs_session}};'
    ## TODO: make sure we don't run around in circles (detect 'use' loops)

    . ' while (!defined($state{should_dispatch}) && @{$state{cfgs_to_check}}) {'
    . ' my $cfg = shift @{$state{cfgs_to_check}};'
    ## TODO: complain loudly? its our bug, we should have
    ## detected this - see use/enable commands need to check for
    ## available configs
    . ' next unless exists $configs{$cfg};'
    . ' $configs{$cfg}->($e, \%state);' . '} '
    . $self->_emit_filter_should_dispatch_def($defaults)
    . ' return $state{should_dispatch};' . ' }' . '}';
}

sub _emit_filter_configs_decl {
  my ($self, $configs) = @_;

  my $decl_code = ' my %configs = (';
  for my $name (sort keys %$configs) {
    $decl_code .= '"' . quotemeta($name) . '" => ' . $configs->{$name} . ",";
  }
  $decl_code .= ');';

  return $decl_code;
}

sub _emit_filter_should_dispatch_def {
  my ($self, $defaults) = @_;

  my $should_dispatch_default = _parse_bool($defaults->{dispatch}, default => 1);

  return ' $state{should_dispatch} = ' . $should_dispatch_default . ' unless defined $state{should_dispatch};';
}

sub _emit_filter_config_per_class_def {
  my ($self, $defaults) = @_;

  return '' unless _parse_bool(delete $defaults->{config_per_class}, default => 1);
  return ' my $e_class = $e->{class}; push @{$state{cfgs_to_check}}, $e_class if exists $configs{$e_class};';
}

sub _emit_filter_fallback_config_def {
  my ($self, $defaults) = @_;
  my $fallback_cfg = delete $defaults->{fallback_config};

  ## FIX: complain if fallback_cfg was not declared

  return '' unless $fallback_cfg;
  return ' push @{$state{cfgs_to_check}}, "' . quotemeta($fallback_cfg) . '";';
}

#         ### Generated if defaults.fallback_config is true, make sure fallback_config exists, complain if not
#

###############################
# Configuration code generation

sub _compile_all_configs {
  my ($self, $configs) = @_;

  my %subs;
  for my $cfg_name (keys %$configs) {
    $subs{$cfg_name} = $self->_compile_config($configs->{$cfg_name});
  }

  ### FIXME: check to see if use|disable/enable => 'config' point to existing configs; complain loudly if not

  return \%subs;
}

sub _compile_config {
  my ($self, $config_spec) = @_;

  my $m = Logan::Filter::Compiler::State->new;

  my $sub_code;
  for my $rule (@{ $config_spec->{rules} }) {
    $sub_code .= $self->_compile_rule($rule, $m);
  }

  return 'sub { my ($e, $s) = @_;' . $sub_code . ' return ; }';
}


######################
# Rule code generation

sub _compile_rule {
  my ($self, $rule, $m) = @_;

  my $cond_code = $self->_compile_condition($rule, $m);
  my $action_code = $self->_compile_action($rule, $m);

  return $cond_code . '{ ' . $action_code . ' }';
}


########################
# Action code generation

sub _compile_action {
  my ($self, $rule, $m) = @_;

  ## FIXME: complain loudly if no actions were found
  return '1' unless exists $rule->{action};

  my $actions     = $rule->{action};
  my $action_code = '';
  my $is_final    = 0;
  for my $action (sort keys %$actions) {
    my ($cmd_code, $cmd_is_final) = $self->_emit_command($action, $actions->{$action}, $rule, $m);
    $action_code .= $cmd_code if $cmd_code;
    $is_final++ if $cmd_is_final;
  }

  $action_code .= 'return;' if $is_final;

  return $action_code;
}

sub _emit_command {
  my ($self, $name, $value) = @_;

  return ('$s->{should_dispatch} = ' . _parse_bool($value) . ';', 1) if $name eq 'dispatch';
  return ('', _parse_bool($value)) if $name eq 'final';

  return ('$s->{cfgs_session}{"' . quotemeta($value) . '"} = 1;',    0) if $name eq 'enable';
  return ('delete $s->{cfgs_session}{"' . quotemeta($value) . '"};', 0) if $name eq 'disable';

  ## FIXME: need to check if at compile time if config $value exists
  return ('unshift @{$s->{cfgs_to_check}}, "' . quotemeta($value) . '";', 0) if $name eq 'use';

  ## FIXME: complain loudly, command not recognized
  return ('', 0);
}

sub _parse_bool {
  my ($bool, %params) = @_;

  $bool = $params{default} unless defined $bool;
  ## FIXME: complain loudly if undef

  return 1 if $bool eq 'true'  or $bool eq '1' or $bool eq 'yes';
  return 0 if $bool eq 'false' or $bool eq '0' or $bool eq 'no';

  ## FIXME: complain loudly
}


######################################
# Condition code generation

sub _compile_condition {
  my ($self, $rule, $m) = @_;

  return '' unless exists $rule->{condition};

  ## FIXME: support nested conditions?
  my $cond      = $rule->{condition};
  my $cond_code = '';
  my @expr_atoms;
  for my $name (sort keys %$cond) {
    my ($check_code, $init_code) = $self->_emit_condition_atom($name, $cond->{$name}, $rule, $m);
    next unless $check_code;

    $cond_code .= $init_code if $init_code;
    push @expr_atoms, $check_code;
  }
  ## FIXME: grep { $_ } should not be needed - if no expression was emited, an error was generated
  my $expr_code = join(' and ', grep {$_} @expr_atoms);

  ## FIXME: we don't need all this after error reporting - either we reported a error or we have $expr_code
  $cond_code .= ' if (' . $expr_code . ') ' if $expr_code;

  return $cond_code;
}

sub _emit_condition_atom {
  my ($self, $name, $value, $rule, $m) = @_;
  ## FIXME: value == undef is not supported, we ignore it with a warning
  return unless defined $value;

  ## IDEA: each atom could be a role that uses after/before on this method and emits the code
  if ($name eq 'class' || $name eq 'subclass') {
    my ($id, $is_new) = $m->atom_id_for($name, $value);
    my $atom = '$a' . $id;
    return ($atom) unless $is_new;
    return ($atom, 'my ' . $atom . ' = $e->{"' . quotemeta($name) . '"} eq "' . quotemeta($value) . '";');
  }

  if ($name eq 'category') {
    my ($id, $is_new) = $m->atom_id_for($name, $value);
    my $atom = '$a' . $id;
    return ($atom) unless $is_new;

    my $atom_v = '$e->{"' . quotemeta($name) . '"}';
    return ($atom,
          'my '
        . $atom
        . ' = exists '
        . $atom_v
        . ' and defined '
        . $atom_v . ' and '
        . $atom_v . ' eq "'
        . quotemeta($value)
        . '";');
  }


  if ($name =~ m{^args[.](.+)$}) {
    my $arg_field = $1;
    my ($id, $is_new) = $m->atom_id_for($name, $value);
    my $atom = '$a' . $id;
    return ($atom) unless $is_new;

    my $atom_v = '$e->{"args"}{"' . quotemeta($arg_field) . '"}';
    return ($atom,
          'my '
        . $atom
        . ' = exists '
        . $atom_v
        . ' and defined '
        . $atom_v . ' and '
        . $atom_v . ' eq "'
        . quotemeta($value)
        . '";');
  }

  ## FIXME: reach here => atom name not recognized => complain <= need error reporting
  die "BAD atom '$name',";
}


#############################
# Compiler state memory utils

package Logan::Filter::Compiler::State;

use Moo;

has 'current_id' => (is => 'rwp', default => sub {0});
has '_meta_map'  => (is => 'ro',  default => sub { {} });

sub next_id {
  my $self = $_[0];

  my $nid = $self->current_id + 1;
  return $self->_set_current_id($nid);
}

sub meta_for {
  my ($self, @keys) = @_;

  my $map = $self->_meta_map;
  while (@keys) {
    my $k = shift @keys;
    $k = defined($k) ? "D $k" : "Undef";
    $map = $map->{$k} ||= {};
  }

  return $map;
}

sub atom_id_for {
  my $self = shift;

  my $map = $self->meta_for(@_);
  return ($map->{id}) if $map->{id};
  return ($map->{id} = $self->next_id, 1);
}

1;
