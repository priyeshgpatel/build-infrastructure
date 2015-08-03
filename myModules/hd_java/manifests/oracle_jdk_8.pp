class hd_java::oracle_java_8 {
  include hd_java::apt_webupd8

  package{ 'oracle-java8':
    name   => 'oracle-java8-installer',
    ensure => present,
    notify => Exec['java8-license-accept'],
  }
#TODO: automatically accept the oracle license, we agree to it
# TODO: probably create an oracle-jdk8 class
# should probably make a hd_java module to manage this stuff
#echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

  exec{ 'java8-license-accept':
    refreshonly => true,
    command     => "/bin/echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections"
  }
}