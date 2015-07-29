class ssl_cert::key_dir {
  group { 'ssl-keys':
    ensure => present,
    gid    => 2000,
  }

  file { '/etc/ssl/keys':
    ensure  => directory,
    owner   => root,
    group   => ssl-keys,
    mode    => 0750,
    require => Group['ssl-keys'],
  }
}