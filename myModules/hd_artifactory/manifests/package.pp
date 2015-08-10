class hd_artifactory::package(
  $version = "4.0.1",
  $base_url = "https://bintray.com/artifact/download/jfrog/artifactory",
  $sha1 = '8d11e3735789a2cbf38e45a4e3709c92b86a703e'
){

  include hd_java::oracle_jdk_8

  archive{ "artifactory-$version":
    name             => "jfrog-artifactory-oss-${version}",
    ensure           => present,
  #url              => "https://bintray.com/artifact/download/jfrog/artifactory/jfrog-artifactory-oss-4.0.1.zip",
    url              => "${base_url}/jfrog-artifactory-oss-${version}.zip",
    purge_target     => true,
    follow_redirects => true,
    target           => "/opt",
    extension        => "zip",
    checksum         => false,
    digest_type      => "sha1",
    digest_string    => $sha1,
    require          => Class['base'],
    notify           => Exec['install_service'],
  }

  file { "artifactory-symlink":
    path    => '/opt/artifactory',
    ensure  => link,
    target  => "/opt/artifactory-oss-${version}",
    require => Archive["artifactory-${version}"]
  }

  exec{ 'install_service':
    refreshonly => true,
    command     => "/opt/artifactory/bin/installService.sh",
    require     => Class['hd_java::oracle_jdk_8']
  }

  service{ 'artifactory':
    ensure    => running,
    require   => Exec['install_service'],
    subscribe => Exec['install_service'],
  }
}