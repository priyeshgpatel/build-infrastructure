class base::nginx {

  include ssl_cert

# Set up a pin for nginx
  apt::pin{ 'backport-nginx':
    priority => 500,
    packages => ['nginx', 'nginx-full', 'nginx-common'],
  }

  package { 'nginx':
    ensure  => present,
    require => Apt::Pin['backport-nginx'],
  }

  exec{ 'dhparam-gen':
    command => "openssl dhparam -out /etc/nginx/dhparam.pem 2048",
    path    => ['/bin', '/usr/bin'],
    cwd     => "/etc/nginx",
    creates => "/etc/nginx/dhparam.pem",
    require => Package['nginx'],
  }

# Don't want the default site running.
  file{ "/etc/nginx/sites-enabled/default":
    ensure  => absent,
    require => Package['nginx'],
  }

  firewall{ '100 nginx http/s access':
    port   => [443,80],
    proto  => tcp,
    action => accept,
  }

  file{ '/etc/nginx/nginx-ssl.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0644,
    source  => "puppet:///modules/base/nginx/ssl-config.conf",
    require => [
      Class['ssl_cert'],
      Package['nginx']
    ],
  }

  service{ 'nginx':
    ensure    => running,
    enable    => true,
    subscribe => Class['ssl_cert'],
    require   => [
      Package['nginx'],
      Class['ssl_cert'],
      Exec['dhparam-gen'],
      File['/etc/nginx/sites-enabled/default']
    ]
  }
}