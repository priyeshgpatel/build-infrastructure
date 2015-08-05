class base::sshd(
  $rsa_host_key = undef,
  $dsa_host_key = undef,
  $ed25519_host_key = undef
) {

# if the keys are specified for the host, then we'll go ahead and replace them on the system
# set up some ssh stuff now
  package{ 'openssh-server':
    ensure => present,
  }

  service{ 'ssh':
    ensure  => running,
    enable  => true,
    require => Package['openssh-server'],
  }
  file{ '/etc/motd':
    ensure  => file,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template("base/motd.erb"),
    require => Package["openssh-server"],
  }
  file{ '/etc/ssh/sshd_config':
    ensure  => file,
    mode    => 0600,
    owner   => root,
    group   => root,
    source  => "puppet:///modules/base/sshd_config",
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  # if we have puppets data for host keys, go ahead and set them
  if $rsa_host_key != undef {
    file{ '/etc/ssh/ssh_host_rsa_key':
      ensure  => file,
      content => $rsa_host_key,
      owner   => root,
      group   => root,
      mode    => 0600,
      require => Package['openssh-server'],
      notify  => Service['ssh']
    }
  }

  if $dsa_host_key != undef {
    file{ '/etc/ssh/ssh_host_dsa_key':
      ensure  => file,
      content => $dsa_host_key,
      owner   => root,
      group   => root,
      mode    => 0600,
      require => Package['openssh-server'],
      notify  => Service['ssh']
    }
  }

  if $ed25519_host_key != undef {
    file{ '/etc/ssh/ssh_host_ed25519_key':
      ensure  => file,
      content => $ed25519_host_key,
      owner   => root,
      group   => root,
      mode    => 0600,
      require => Package['openssh-server'],
      notify  => Service['ssh']
    }
  }


}