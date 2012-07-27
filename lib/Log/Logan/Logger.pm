package Log::Logan::Logger;

# ABSTRACT: the Logger object, represents a logging session
# VERSION
# AUTHORITY

use Moo;
with 'Log::Logan::Logger::Core',    ## Must be the first one
  'Log::Logan::Logger::Logger',
  'Log::Logan::Logger::MessageFmt',
  'Log::Logan::Logger::Caller', 'Log::Logan::Logger::TStamp',    ## Try to keep TStamp as the last one, better accuracy
  ;


1;
