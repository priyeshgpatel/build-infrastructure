class puppet_master {
# puppet master class for debian

# using https://github.com/TomPoulton/hiera-eyaml
# need our eyaml backend
  package{ "hiera-eyaml":
    ensure   => installed,
    provider => 'gem',
  }

# a puppetlabs provided package that includes passenger and pre configures all the things, woot
  package{ "puppetmaster-passenger":
    ensure => present,
  }

  exec{ "/usr/sbin/a2enmod ssl":
    require => Package["libapache2-mod-passenger"],
    creates => "/etc/apache2/mods-enabled/ssl.load",
  }

  exec{ "/usr/sbin/a2enmod headers":
    require => Package["puppetmaster-passenger"],
    creates => "/etc/apache2/mods-enabled/headers.load",
  }

  exec{ "/usr/sbin/a2dissite default":
    require => Package["puppetmaster-passenger"],
  }

  exec{ "/usr/sbin/a2ensite puppetmaster":
    require => [
      Package["puppetmaster-passenger"]
    ],
    creates => "/etc/apache2/sites-enabled/puppetmaster",
  }

  firewall{ '100 puppetmaster port':
    port   => 8140,
    proto  => 'tcp',
    action => 'accept',
  }

  service{ "apache2":
    ensure  => running,
    enable  => true,
    require => [
      Package['puppetmaster-passenger'],
      Exec["/usr/sbin/a2enmod ssl", "/usr/sbin/a2enmod headers"],
      Firewall['100 puppetmaster port'],
    ]
  }

  file{ "/usr/local/bin/puppet-repo-sync.sh":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0754,
    source => "puppet:///modules/puppet_master/puppet-repo-sync.sh",
  }

  cron{ 'repo-sync':
    command => "/usr/local/bin/puppet-repo-sync.sh",
    user    => root,
    minute  => "*/15",
    require => File["/usr/local/bin/puppet-repo-sync.sh"]
  }
}