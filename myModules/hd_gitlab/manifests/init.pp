class hd_gitlab(
  $external_hostname = hiera('external_fqdn', $fqdn),
  $gitlab_repo_disk = 'google-gitlab-repo-disk'
) {
# gitlab needs sending
  include base::mail_sender

  include ssl_cert

# get our package installed!
  include hd_gitlab::package

#TODO: centralized authentication?

  firewall{ '100 gitlab http/s access':
    port   => [443,80],
    proto  => tcp,
    action => accept,
  }


# the gitlab repo disk is not part of the base image, so we have more space
  file{ '/srv/gitlab-repo':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0755,
  } ~>
  mount{ 'gitlab_repo_mount':
    name    => '/srv/gitlab-repo',
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/disk/by-id/google-gitlab-repo-disk',
    fstype  => 'ext4',
    options => 'defaults,noatime',
  }

# have to link the certs to /etc/gitlab/ssl
  file{ '/etc/gitlab/ssl':
    ensure  => directory,
    owner   => root,
    group   =>root,
    mode    => 0700,
    require => Package['gitlab-ce'],
    before  => File['/etc/gitlab/gitlab.rb'],
  } ~>
  file{ '/etc/gitlab/ssl/git.hdtechlab.com.crt':
    ensure => link,
    target => '/etc/ssl/certs/build.gc.hdtechlab.com.crt',
    notify => Exec['gitlab-reconfigure'],
  } ~>
  file{ '/etc/gitlab/ssl/git.hdtechlab.com.key':
    ensure => link,
    target => '/etc/ssl/keys/build.gc.hdtechlab.com.key',
    notify => Exec['gitlab-reconfigure'],
  }

# this is the primary gitlab configuration file, it's big.
  file{ '/etc/gitlab/gitlab.rb':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0600,
    content => template('hd_gitlab/gitlab.rb.erb'),
    notify  => Exec['gitlab-reconfigure'],
    require => Mount['gitlab_repo_mount'],
  }

  exec{ 'gitlab-reconfigure':
    command     => '/usr/bin/gitlab-ctl reconfigure',
    subscribe   => Package['gitlab-ce'],
    refreshonly => true,
  }


# set up a cron for backups
  cron{ 'gitlab-backup':
    command => '/opt/gitlab/bin/gitlab-rake gitlab:backup:create',
    user    => root,
    hour    => 2,
    minute  => 0
  }
}