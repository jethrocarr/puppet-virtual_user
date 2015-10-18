# Define user accounts to group multiple resources together, making it very
# easy to use as virtual resources that are then realised.
#
# TIP:
# Refer to the Puppet resource documentation at
# https://docs.puppetlabs.com/references/latest/type.html to learn more about
# the different resources and parameters used below.

define virtual_user (
  $username       = $name,
  $ensure         = 'present',
  $uid            = undef,
  $gid            = $uid,
  $home           = "/home/${name}",
  $shell          = "/bin/bash",
  $password_hash  = undef,
  $managehome     = true,
  $groups         = [],
  $ssh_key_type   = undef,
  $ssh_key_pub    = undef,
  $ssh_key_purge  = true,
  $tags           = [],
) {

  if (!$uid) {
    fail("A uid must be provided for user ${username}")
  }

  # Clean up removal of users/groups properly.
  if $ensure == 'absent' {
    User[$username] -> Group[$username]
  }

  # Create the user account (and associated group).
  user { $username:
    ensure         => $ensure,
    uid            => $uid,
    gid            => $gid,
    groups         => $groups,
    home           => $home,
    shell          => $shell,
    password       => delete(chomp($password_hash), ' '), # remove any accidental whitespace from line wrapping
    managehome     => $managehome,
    purge_ssh_keys => $ssh_key_purge,
  }

  group { $username:
    ensure => $ensure,
    gid    => $gid,
  }


  # If an SSH key has been provided, we set it up as an authorized key for user logins.
  # 

  if (!$ssh_key_pub and $ssh_key_type) {
    fail("You must specify both a ssh_key_pub string and ssh_key_type (ssh-rsa or ssh-dsa) for user ${username}")
  }
  if ($ssh_key_pub and !$ssh_key_type) {
    fail("You must specify both a ssh_key_pub string and ssh_key_type (ssh-rsa or ssh-dsa) for user ${username}")
  }

  if ($ssh_key_type and $ssh_key_pub) {
    ssh_authorized_key { $username:
      ensure => $ensure,
      user   => $username,
      type   => $ssh_key_type,
      key    => delete(chomp($ssh_key_pub), ' '), # remove any accidental whitespace from line wrapping
    }
  }



}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
