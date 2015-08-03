class hd_gitlab(
  $http_url = undef,
  $external_hostname = undef,
  $gitlab_repo_disk = 'google-gitlab-repo-disk'
) {
# gitlab needs sending
  include base::mail_sender

#TODO: eventually we're going to want HTTPS. Maybe i'll just do a self-signed cert for now...
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

  # this is the primary gitlab configuration file, it's big.
  file{ '/etc/gitlab/gitlab.rb':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0600,
    content => template('hd_gitlab/gitlab.rb.erb'),
    notify  => Exec['gitlab-reconfigure'],
    require => File_line['gitlab_repo_filesystem'],
  }

  exec{ 'gitlab-reconfigure':
    command     => '/usr/bin/gitlab-ctl reconfigure',
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