# puppet-virtual_user

A very simple lightweight user module. You've seen this module before, pretty
much every Puppet-using site ends up with some form of this, mine is shared
for reference if you wish to use it.

# Usage

## Basic Usage

The way to use this module is always to invoke the `virtual_user` resource as
a virtual and then "realize" it on the systems you want the user accounts on.

At it's simplest, you can define a user account as per the following example:

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

If you set `puppet_controlled_pw => false` the module will create an initial 
password specified as a hash in `password_hash` and configure the account to 
require a new password to be set on first login. If the password is not changed
within 7 days (default), the account is disabled. This allows users to control 
their own passwords separately from puppet. If you do not set `password_hash`,
a default of `this.is.insecure` will be used. Example:

    # Define virtual user Jane. This means Jane won't be applied, unless we
    # realise her later on. She will have to change her password on first login.
    # As no password_hash is defined, the default will be used. If she does not 
    # change her password within 3 days, her account will be deactivated.
    @virtual_user { 'jane':
      uid                  => '1000',
      groups               => ['wheel'],
      puppet_controlled_pw => false,
      inactive             => '3',
    }
    
    # Here we "realize" the specific user Jane
    realize(Virtual_user['jane'])

If you want to do more complex things or tinker, check out the
`manifests/init.pp` file for the full list of params; we make some assumptions
by default, such as creating the home directory and purging any other SSH
authorized keys that aren't explicitly configured.


## Hiera Example

If you're using Hiera (recommended) then you can easily define all the user
accounts in Hiera and use a couple of lines in a Puppet manifest to generate all
the virtual users from that.

The following is an example of inheriting data from Hiera with the Puppet
manifest:

    # Generate all users from Hiera data
    create_resources("@virtual_user", hiera(virtual_users))

    # Realize the SOE users here.
    Virtual_user <| tags == soe |>


The following is the associated example Hiera configuration:

    virtual_users:
      jane:
        uid: 1000
        groups:
         - wheel
        password_hash: >
          gEWyw234egW@$YWU@$WHR#%YHR#$^Q%WY$RH^Q#$WEGQ#%Y$RWHQ#^TYGW#%Ysy423teg4y4s
          tg23tygway4h234wag34yhwahgw34yh4d
        ssh_key_pub: >
          ZZZZZRH34e2hw4eghq234yh2wh23hq123hy23gh4w3h4h2wheh4w4h4h2w4wahg43qewg23hy
          gk.234hgilo2bw,gbjk2b34jktgblwl3jt;gjwj4;tjgklw34jfg4h34h43yhhh444h4hh4hf
        ssh_key_type: ssh-rsa
        tags:
         - soe

Note the use of the `>` charactor with `password_hash` and `ssh_key_pub`, this
allows you to split the long hash and SSH key strings across multiple lines if
desired to keep things tidier/more readable.


# Additional Tips

If you don't have existing password hashes handy and wish to use them (eg you
plan to do PAM auth for non-cert based services like Apache), you can use the
unix-crypt gem (https://github.com/mogest/unix-crypt) to generate suitable
password hashes for user accounts.

If you wish to learn more about virtual resources, refer to:
https://docs.puppetlabs.com/guides/virtual_resources.html



# Dependencies

Requires stdlib, no others.


