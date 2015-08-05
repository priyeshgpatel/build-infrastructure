class mumble_server(
  $mumble_password = undef
)
{
#Get the SSL Certs on the machine
  include ssl_cert

  package { "mumble-server":
    ensure => present
  }

#make sure the mumble-server user is in the ssl-keys group
  user{ "mumble-server":
    ensure  => present,
    groups  => ["mumble-server", "ssl-keys"],
    require => [
      Class["ssl_cert"],
      Package["mumble-server"],
    ]
  }

  file{ "/etc/mumble-server.ini":
    ensure  => file,
    owner   => 'mumble-server',
    group   => 'mumble-server',
    mode    => 0640,
    content => template("mumble_server/mumble-server.ini.erb"),
    require => Package['mumble-server'],
    notify  => Service['mumble-server'],
  }

  service{ "mumble-server":
    ensure  => running,
    enable  => true,
    require => [
      Package["mumble-server"],
      File["/etc/mumble-server.ini"],
      User["mumble-server"],
      Class["ssl_cert"]
    ],
  }

#set up stuff to backup the sqlite database for mumble
  package{ "ruby-sqlite3":
    ensure => present,
  }

  file{ '/srv/mumble_database':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0755
  }

  file{ '/usr/local/bin/backup.rb':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0770,
    source  => 'puppet:///modules/mumble_server/backup.rb',
    require => [
      Package['ruby-sqlite3']
    ],
  }

# nightly backup of the mumble database
  cron{ 'mumble_backup':
    command => '/usr/local/bin/backup.rb',
    user    => root,
    hour    => 4,
    minute  => 0,
    require => File['/usr/local/bin/backup.rb'],
  }

# here's where we're going to forward 443 to the mumble port
# figured out how to do this from: https://www.tiredpixel.com/2013/09/02/iptables-port-forwarding-using-puppet/
  firewall{ '102 forward TCP 443 to 64738':
    table   => 'nat',
    chain   => 'PREROUTING',
    proto   => 'tcp',
    dport   => '443',
    jump    => 'REDIRECT',
    toports => '64738',
  }

  firewall{ '103 forward UDP 443 to 64738':
    table   => 'nat',
    chain   => 'PREROUTING',
    proto   => 'udp',
    dport   => '443',
    jump    => 'REDIRECT',
    toports => '64738',
  }

  firewall{ '100 accept TCP 64738':
    port   => 64738,
    proto  => tcp,
    action => accept,
  }

  firewall{ '101 accept UDP 64738':
    port   => 64738,
    proto  => udp,
    action => accept,
  }
}