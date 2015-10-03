# puppet-users

A very simple lightweight user module. You've seen this module before, pretty
much every Puppet-using site ends up with some form of this, mine is shared
for reference if you wish to use it.

# Usage


If you don't have existing password hashes handy and wish to use them (eg you
plan to do PAM auth for non-cert based services like Apache), you can use the
unix-crypt gem (https://github.com/mogest/unix-crypt) to generate suitable
password hashes for user accounts. 



# Dependencies

Requires stdlib, no others.


