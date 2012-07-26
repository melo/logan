package Log::Logan::Logger;

# ABSTRACT: the Logger object, represents a logging session
# VERSION
# AUTHORITY

use Moo;
with 'Log::Logan::Logger::Core', 'Log::Logan::Logger::MessageFmt';

1;
