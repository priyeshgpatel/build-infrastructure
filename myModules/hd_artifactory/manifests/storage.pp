class hd_artifactory::storage {

  include hd_artifactory::package
# set up the mounts, and then ensure the file_line for the location
# the gitlab repo disk is not part of the base image, so we have more space
  file{ '/srv/artifactory-data':
    ensure  => directory,
    owner   => artifactory,
    group   => artifactory,
    mode    => 0755,
    require => Class['hd_artifactory::package'],
  } ~>
  mount{ 'artifactory_repo_mount':
    name    => '/srv/artifactory-data',
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/disk/by-id/google-artifactory-repo',
    fstype  => 'ext4',
    options => 'defaults,noatime',
  } ~>
  file_line { "artifactory-storage-setting":
    ensure  => present,
    line    => "binary.provider.filesystem.dir = /srv/artifactory-data",
    path    => "/etc/opt/jfrog/artifactory/storage.properties",
  }

}