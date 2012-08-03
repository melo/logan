package Logan::Session;

# ABSTRACT: the Session object, represents a Logan session
# VERSION
# AUTHORITY

use Moo;
with 'Logan::Session::Core',    ## Must be the first one
  'Logan::Session::Stash',
  'Logan::Session::Data',
  'Logan::Session::API::Logger',
  'Logan::Session::API::Audit',
  'Logan::Session::Event::MessageFmt',
  'Logan::Session::Event::Caller',
  'Logan::Session::Event::TStamp',    ## Try to keep TStamp as the last one, better accuracy
  ;

1;
