# Define user accounts to group multiple resources together, making it very
# easy to use as virtual resources that are then realised.
#
# TIP:
# Refer to the Puppet resource documentation at
# https://docs.puppetlabs.com/references/latest/type.html to learn more about
# the different resources and parameters used below.

define virtual_user (
  $username             = $name,
  $ensure               = 'present',
  $uid                  = undef,
  $gid                  = $uid,
  $home                 = "/home/${name}",
  $shell                = "/bin/bash",
  $password_hash        = undef,
  $managehome           = true,
  $groups               = [],
  $ssh_key_type         = undef,
  $ssh_key_pub          = undef,
  $ssh_key_purge        = true,
  $tags                 = [],
  $password_max_age     = '17144',
  $password_min_age     = '0',
  $inactive             = '7',
  $puppet_controlled_pw = true,
  $comment              = undef,
) {

  if $puppet_controlled_pw {
    if $password_hash == undef {
      fail("A password hash for user ${username} needs to be provided for a puppet controlled password")
    } else {
      $firstpw = delete(chomp($password_hash), ' ') # remove any accidental whitespace from line wrapping
      $offset  = Timestamp.new.strftime("%s") / 86400
      $password = $firstpw
    }
  } else { 
      if $password_hash == undef {
        # Initial password is set to "this.is.insecure"
        $firstpw = '$6$wt56xSu5$UvdMe7flLJHRuiMooXy8eE5aOVNVMZjfAPeBAafzfVYor4tWecp5UafnQ8Fm3Jbu6OpiQm.IpX.j7qFO5g9iO1'
      } else {
        $firstpw = $password_hash
      }
      # Forces new password at first login
      $offset  = Timestamp.new.strftime("%s") / 86400 - 17145    
  }
    
  if (!$uid) {
    fail("A uid must be provided for user ${username}")
  }

  # Clean up removal of users/groups properly.
  if $ensure == 'absent' {
    User[$username] -> Group[$username]
  }

  # Create the user account (and associated group).
  user { $username:
    ensure           => $ensure,
    uid              => $uid,
    gid              => $gid,
    groups           => $groups,
    home             => $home,
    shell            => $shell,
    managehome       => $managehome,
    purge_ssh_keys   => $ssh_key_purge,
    password_max_age => $password_max_age,
    password_min_age => $password_max_age,
    password         => $password,
    comment          => $comment,
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
  exec { "setfirstpw_${username}":
    command => "/usr/sbin/usermod -p '${firstpw}' $username -f $inactive ;/usr/bin/chage -d '${offset}' '${username}'",
    onlyif => "/bin/egrep -q '^${username}:[*!]' /etc/shadow",
    require => User[$username];
  }
}

# vi:smartindent:tabstop=2:shiftwidth=2:expandtab:
