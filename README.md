# puppet-virtual_user

A very simple lightweight user module. You've seen this module before, pretty
much every Puppet-using site ends up with some form of this, mine is shared
for reference if you wish to use it.

# Usage

The way to use this module is always to invoke the `virtual_user` resource as
a virtual and then "realize" it on the systems you want the user accounts on.

At it's simpliest, you can define a user account as per the following example:

   # Define virtual user Jane. This means Jane won't be applied, unless we
   # realise her later on.
   @virtual_user { 'jane':
      uid           => '1000',
      groups        => ['wheel'],
      password_hash => 'hash',
      ssh_key_pub   => 'longkeyislong',
      ssh_key_type  => 'ssh-rsa',
      tags          => ['soe'],
    }
    
    # Here we "realize" any user whom includes the tag of SOE, this will catch
    # our Jane example from above and ensure she has an account on this server.
    Virtual_user <| tags == soe |>


If you want to do more complex things or tinker, check out the
`manifests/init.pp` file for the full list of params, we make some assumptions
by default, such as creating the home directory and purging any other SSH
authorized keys that aren't explicity configured.

This module is Hiera-friendly, the way you should use it is define the users in
Hiera and then add the following code to generate the virtual resources from
hiera.



# Additional Tips

If you don't have existing password hashes handy and wish to use them (eg you
plan to do PAM auth for non-cert based services like Apache), you can use the
unix-crypt gem (https://github.com/mogest/unix-crypt) to generate suitable
password hashes for user accounts.

If you wish to learn more about virtual resources, refer to:
https://docs.puppetlabs.com/guides/virtual_resources.html



# Dependencies

Requires stdlib, no others.


