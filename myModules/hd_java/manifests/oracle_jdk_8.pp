class hd_java::oracle_java_8 {
  include hd_java::apt_webupd8

  package{ 'oracle-java8':
    name   => 'oracle-java8-installer',
    ensure => present,
    notify => Exec['java8-license-accept'],
  }

  exec{ 'java8-license-accept':
    refreshonly => true,
    command     => "/bin/echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections"
  }
}