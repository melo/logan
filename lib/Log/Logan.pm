package Log::Logan;

# ABSTRACT: a very cool module
# VERSION
# AUTHORITY

use Moo;
use Scalar::Util 'blessed';
use namespace::autoclean;


### Per-class singleton management
{
  our %instances;

  sub instance {
    my $class = shift;
    return $instances{$class} || $class->setup(@_);
  }

  sub setup {
    my $class = shift;

    return $instances{$class} = $class->new(@_);
  }
}


### Logger access
has 'logger_class' => (is => 'ro', builder => 'default_logger_class');
sub default_logger_class {'Log::Logan::Logger'}

sub logger {
  my $self = shift;
  $self = $self->instance unless blessed($self);

  $self->logger_class->new(@_, logan => $self);
}


### Event dispatching
sub process {
  my ($self, $event) = @_;

  $self->dispatch($event);

  return 1;
}


1;

__END__

=encoding utf8

=head1 SYNOPSIS

    ## Declare you Logan-based App logger
    package My::App::Logan;
    
    use Moo;     ## Or Moose, choose your poison
    with 'Log::Logan::Core';
    
    sub config {
      ## Must return HashRef with configuration
    }
    
    sub dispatch {
      my ($class, $event) = @_;

      ## do whatever you want with $event
    }
    
    1;


    ## Another App logger, reusing a Message::Passing dispatcher
    package Other::App::Logan;
        
    use Moo;
    with 'Log::Logan::Core', 'Log::Logan::Dispatch::Message::Passing';
    
    sub config {
      ## Must return HashRef with configuration
    }
    
    1;


    ## Yet Another App logger, with a lot of defaults
    package YA::App::Logan;
        
    use Moo;
    with 'Log::Logan::Core',
         'Log::Logan::Dispatch::Message::Passing',
         'Log::Logan::Config::File';

    1;


    ## At the start of a logging session, create a Logger
    ## For example in a app.psgi:
    use Plack::Builder;
    
    my $app = sub {};
    
    builder {
      enable sub {
        my $env = shift;
        $env->{'my_app.logger'} = My::App::Logan->get_logger();
      };
      
      $app;
    };  


    ## Inside your app use the logger
    ## For example, a Dancer app
    use Dancer;
    
    get '/' => sub {
        my $logger = request->env->{'my_app.logger'};
        
        $logger->info('Another happy customer!');
        
        return "Hi, how are you? :)";
    };
    
    dance;


=head1 DESCRIPTION

The L<Log::Logan> module is not a complete logging solution but a
building block that you can integrate with your own system.

This module provides the following items:

=over 4

=item an API for structured logging

Log not only a text message but any serializable (scalars, lists, and hashes) Perl
data structures.

=item user-defined filtering rules

Use different logging conditions based on bussiness logic.

Maybe you need to trace a particular user, or increase log level if a user
enters a particular condition on your code. Your choice.

=item live reconfiguration

Reconfigure everything on-the-fly: filtering rules can be updated
whenever you need, log destination can change while the application is
still running.

Use any source you want for configuration storage: local files, URLs,
a Redis/memcached key, a DBI query; if you can code it in Perl, you
can use it.

=item asynchronous log dispatch

The default log dispatcher uses L<Message::Passing::ZeroMQ> to provide
asynchronous log dispatch. After serialization, all network logic and I/O is
performed by a different thread.

But even this you can change if you so wish.

=back


=head2 Goals

The main goal is not to build a logging system that will work in
multi-million requests per day system (given that I haven't had to deal
with one of those in quite some time).

The main goal is to have a system that can be used by a small or even
single-person team, to diagnose problems in a medium-sized application
with multiple elements/instances (defined here as having about 250
packages, spread over a two or three PSGI apps plus a large set of
cronjobs and/or asynchronous job system workers).

One example of the flexibility we expect to achive is to be able to
declare something like "track all interactions of user X at severity
trace on categories payments and shopping_cart when he starts the
checkout process", and have those settings be applied with the least
delay possible (less than 15 seconds) to all future web requests, cron
jobs and job worker runs, while being possible to correlate events, like
determining which web request was responsible for a particular job
worker run.

Oh yes, and try to have as little impact as possible on your app performance.

=head2 How to use Logan

This is the best current practice on how to use Logan.

Inside your app, create a subclass of L<Log::Logan>. This is the class
that will track the current active configuration, and the current active
log event destination. This is your App::Logger class, the entry point for all things Logan.

When you need to log something you create a L<Log::Logan::Logger> object
using the C<get_logger()> API on your App::Logger class. The Logger has
a unique ID associated with it (you also can provide your own) and this
can be used to correlate log events to the same application request. You
should consider the Logger a representation of a logging session, where
all log events share a logging session ID.

You can also associate logging session data to the Logger. You could,
for example, add the user ID for the person making the Web request. Or
the IP address of the user. This logging session data is sent as a
special log event tagged with the same logging session ID everytime you
update it.

You create log events using the methods in the Logger class. You have
one method per severity, plus a couple of extra events.


=head2 Main concepts

The Logan logger is based on a set of core concepts.

=head3 Logger

A Logger object is create per run/request. It provides the unique Sequence ID
that identifies this logging run.

=head3 Log Event

Each time you call one of the logger methods, a new Log event is
created. Each event has a Message Format and optionally associated Message Data.

All Events have a Sequence ID, that they receive from the Logger that
generated the event.

=head3 Message Format

A format string used to generate the textual representation of the Log Message.

The string can contain placeholder markers that are replaced with the
content of specific fields from the Message Data.

=head3 Message Data

Information about the context of the Message. It includes a Category, a
Severity, caller context information (optionally partial or full
backtrace), and User Data.

=head3 Category

Each Log Event has a Category, a string. The end user can define the
Category on any call to a logger API. If not provided, Logan will
generate a Category using the caller package name and sub name.

=head3 Severity

Each Log Event has a Severity, a integer in the range 0 to 100 where 0
is the least critical and 100 is the most critical.

Humans though, deal better with descriptive names so we also accept the
following labels (and their respective associated Severities):

=over 4

=item FATAL: 90

=item CRITICAL: 80

=item ERROR: 70

=item WARN: 60

=item INFO: 50

=item DEBUG:30

=item TRACE:10

=back

=head3 User Data

A HashRef of user data included in the message data. You can put
anything you might need to interpret the message later in here, even if
you don't use them in a placeholder on the message format string.

Please note that the information in the message data will most likelly
be serialized by Destinations to print or send over the network, so you
should limit your user data to undef, Scalars, HashRefs and ArrayRefs.


TODO: Destination
TODO: Configuration




=cut
