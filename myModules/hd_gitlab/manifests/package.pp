class hd_gitlab::package {
# set up all the apt stuff for gitlab, and get the package installed
  include apt

  apt::key{ 'gitlab_key':
    ensure => present,
    source => "https://packages.gitlab.com/gpg.key",
  }

# NOTE: apt-transport-https is specified in the base manifest
  apt::source{ 'gitlab_repo':
    comment  => "gitlab packages repo",
    location => "https://packages.gitlab.com/gitlab/gitlab-ce/debian",
    release  => "wheezy",
    repos    => "main",
    include  => {
      'src' => true,
      'deb' => true
    },
    require  => [
      Apt::Key['gitlab_key'],
      Package['apt-transport-https']
    ],
  }

  package{ 'gitlab-ce':
    ensure  => installed,
    require => Apt::Source['gitlab_repo'],
  }
}