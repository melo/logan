package Log::Logan::Session;

# ABSTRACT: the Session object, represents a Logan session
# VERSION
# AUTHORITY

use Moo;
with 'Log::Logan::Session::Core',    ## Must be the first one
  'Log::Logan::Session::Data',
  'Log::Logan::Session::Logger',
  'Log::Logan::Session::Audit',
  'Log::Logan::Session::MessageFmt',
  'Log::Logan::Session::Caller', 'Log::Logan::Session::TStamp',   ## Try to keep TStamp as the last one, better accuracy
  ;


1;
