package Logan::Session;

# ABSTRACT: the Session object, represents a Logan session
# VERSION
# AUTHORITY

use Moo;
with 'Logan::Session::Core',    ## Must be the first one
  'Logan::Session::Data',
  'Logan::Session::Logger',
  'Logan::Session::Audit',
  'Logan::Session::MessageFmt',
  'Logan::Session::Caller', 'Logan::Session::TStamp',   ## Try to keep TStamp as the last one, better accuracy
  ;


1;
