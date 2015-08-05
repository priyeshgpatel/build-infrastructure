class base(
  $rxvt_terminfo = "ncurses-term"
) {

# base configuration for all nodes managed by this puppetmaster
  class { ['base::fw_pre', 'base::fw_post']: }
  class { 'firewall': }

# include ssh setup stuff in it's own class
  include base::sshd


# 1 GB Swap
  base::swap{ 'swapfile':
    swapfile => '/swapfile',
    swapsize => 1024
  }

  file { '/etc/profile.d/ls.sh':
    ensure => present,
    source => 'puppet:///modules/base/profile-ls.sh',
    mode   => "0755",
    owner  => root,
    group  => root,
  }

  package{ 'tmux':
    ensure => present,
  }

  file{ "/etc/tmux.conf":
    ensure  => present,
    source  => "puppet:///modules/base/tmux.conf",
    mode    => "0664",
    owner   => root,
    group   => root,
    require => Package['tmux'],
  }

  package{ 'apt-transport-https':
    ensure => present,
  }

  package{ 'wget':
    ensure => present,
  }

  package{ 'unzip':
    ensure => present,
  }

  package{ 'bzip2':
    ensure => present,
  }

# why wasn't less installed?!?!? I dunno
  package{ 'less':
    ensure => present,
  }

  package{ 'haveged':
    ensure => present,
  }

  service{ "haveged":
    ensure  => running,
    enable  => true,
    require => Package["haveged"],
  }

# I run URXVT and I can never less or anytyhing, because missing terminfo!
# debian provides a handy terminfo package, so I don't need to install all of the urxvt stuff
  package{ 'rxvt-unicode-terminfo':
    name => $rxvt_terminfo
  }

  package{ 'chrony':
    ensure => present,
  }

  file{ 'chrony_config':
    ensure  => present,
    path    => "/etc/chrony.conf",
    source  => "puppet:///modules/base/chrony-client.conf",
    mode    => "0660",
    owner   => root,
    group   => root,
    require => Package["chrony"],
    notify  => Service["chrony"],
    backup  => false,
  }

  service{ "chrony":
    ensure  => running,
    enable  => true,
    require => [
      Package["chrony"],
      File["chrony_config"]
    ],
  }

  file { '/etc/localtime':
    ensure => link,
    target => '/usr/share/zoneinfo/CST6CDT',
    backup => false,
  }

  file { '/etc/default/puppet':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => "0644",
    source => "puppet:///modules/base/puppet-agent",
    notify => Service['puppet'],
  }

  service{ "puppet":
    ensure  => running,
    enable  => true,
    require => File['/etc/default/puppet'],
  }

  package{ "rsyslog":
    ensure => present,
  }

  file{ "/etc/rsyslog.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template("base/rsyslog.conf.erb"),
    require => Package['rsyslog'],
    notify  => Service['rsyslog'],
  }

  service{ "rsyslog":
    ensure  => running,
    enable  => true,
    require => [
      Package["rsyslog"],
      File["/etc/rsyslog.conf"]
    ],
  }

# adding tmpreaper to keep the /tmp dir cleaned up
  package{ 'tmpreaper':
    ensure => present,
  }

  file{ '/etc/tmpreaper.conf':
    ensure  => file,
    mode    => 0640,
    owner   => root,
    group   => root,
    source  => "puppet:///modules/base/tmpreaper.conf",
    require => Package['tmpreaper'],
  }

# ssh host key knowledge
# most of the hosts will need access to one or both of these, and knowledge of them won't hurt
  $github_key_info = hiera_hash("base::github_host_key", { "key" => "DEFAULT", "type" => "ssh-rsa" })

  sshkey{ 'github.com':
    ensure => present,
    name   => $github_key_info["name"],
    key    => $github_key_info["key"],
    type   => $github_key_info["type"],
  }
#TODO: will need a gitlab host key for our existing gitlab, chicken egg problem?

#https://tickets.puppetlabs.com/browse/PUP-1177
# turns out puppet creates this file rather stupidly.
  file{ "/etc/ssh/ssh_known_hosts":
    ensure  => file,
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Sshkey["github.com"],
  }

# schedule a cron update every 4 hours to get the latest package information
  cron{ 'cron-apt-get-update':
    ensure  => present,
    command => '/usr/bin/apt-get update',
    user    => root,
    hour    => '*/4',
    minute  => 0,
  }

}
