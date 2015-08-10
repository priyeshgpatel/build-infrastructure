class hd_artifactory {
# have to download and install the zip manually :(
  include hd_artifactory::package
  include hd_artifactory::storage

# can't notify on a change to the install service, becaues it happens on every puppet run :(
  service{ 'artifactory':
    ensure    => running,
    require   => Class['hd_artifactory::package', 'hd_artifactory::storage'],
  }

  include base::nginx::autohttps

  $external_fqdn = hiera("external_fqdn", $fqdn)

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