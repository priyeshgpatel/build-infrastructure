class hd_java::oracle_jdk_8 {
  include hd_java::apt_webupd8

  package{ 'oracle-java8':
    name    => 'oracle-java8-installer',
    ensure  => present,
    require => Class['jd_java::apt_webupd8'],
  }

  exec{ 'java8-license-accept':
    command     => "/bin/echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections",
    before      => Package['oracle-java8'],
    unless      => '/usr/bin/debconf-get-selections | /bin/egrep "oracle-java8-installer.*shared.*true"'
  }
}