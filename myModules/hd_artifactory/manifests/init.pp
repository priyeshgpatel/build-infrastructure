class hd_artifactory {
# have to download and install the zip manually :(
  include hd_artifactory::package
  include hd_artifactory::storage

  service{ 'artifactory':
    ensure    => running,
    require   => Class['hd_artifactory::package', 'hd_artifactory::storage'],
    subscribe => Exec['install_service'],
  }

  include base::nginx::autohttps

  file{ "/etc/nginx/conf.d/artifactory.conf":
    ensure  => file,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template("hd_artifactory/nginx.conf.erb"),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
}