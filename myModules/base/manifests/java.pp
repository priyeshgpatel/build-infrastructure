class base::java {
# TODO: set up the oracle jdk8 PPA repo and stuff in here, for use by other systems that want a java
# Super handy: http://www.webupd8.org/2014/03/how-to-install-oracle-java-8-in-debian.html

  include apt
  apt::key{ 'webupd8key':
    id     => 'EEA14886',
    server => 'keyserver.ubuntu.com',
  }

  apt::ppa{ 'ppa:webupd8team/java': }
}