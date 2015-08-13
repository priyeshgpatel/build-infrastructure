class hd_gitlab::package(
  $gitlab_version = "installed"
) {
# set up all the apt stuff for gitlab, and get the package installed
  include apt

  apt::key{ 'gitlab-key':
    id     => "1A4C919DB987D435939638B914219A96E15E78F4",
    ensure => present,
    source => "https://packages.gitlab.com/gpg.key",
  }

# NOTE: apt-transport-https is specified in the base manifest
  apt::source{ 'gitlab-repo':
    comment  => "gitlab packages repo",
    location => "https://packages.gitlab.com/gitlab/gitlab-ce/debian",
    release  => "wheezy",
    repos    => "main",
    include  => {
      'src' => true,
      'deb' => true
    },
    require  => [
      Apt::Key['gitlab-key'],
      Package['apt-transport-https']
    ],
  }

# create an apt-pin to keep this guy from nagging me, for now.
# if I specified a version
  if($gitlab_version != "installed") {
    $pin_ensure = "present"
  } else {
    $pin_ensure = "absent"
  }

  apt::pin{ 'gitlab-ce-pin':
    ensure    => $pin_ensure,
    version   => $gitlab_version,
    priority  => 500,
    packages  => ['gitlab-ce'],
  }
  
  package{ 'gitlab-ce':
    ensure  => $gitlab_version,
    require => Apt::Source['gitlab-repo'],
  }
}