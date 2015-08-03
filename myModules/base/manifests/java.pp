class base::java {
# Super handy: http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html

  include apt

  apt::source { 'webupd8Java':
    comment => 'webupd8 Oracle Java repository',
    location => 'http://ppa.launchpad.net/webupd8team/java/ubuntu',
    release  => 'trusty',
    repos    => 'main',
    key      => {
      'id'     => 'EEA14886',
      'server' => 'keyserver.ubuntu.com',
    },
    include  => {
      'src' => true,
      'deb' => true,
    },
  }

  #TODO: automatically accept the oracle license, we agree to it
  # TODO: probably create an oracle-jdk8 class
  # should probably make a hd_java module to manage this stuff
  #echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
}