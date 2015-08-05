class hd_jenkins::build_tools::maven(
  $jenkins_home = undef,
) {
  # TODO: finish this guy
# ensure maven is installed
# see https://forge.puppetlabs.com/maestrodev/maven for many examples, including how to set up ~/.m2/settings.xml
  class{ "maven::maven":
    version => "${maven_version}",
  }


# specify some maven options for jenkins
# had to specify the user home, because it doesn't facter it :|
  maven::environment { 'maven-jenkins':
    user       => 'jenkins',
    home       => "${jenkins_home}",
    maven_opts => '-Xms512m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:-UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled',
    require    => [
      User["jenkins"]
    ],
  }

# adding a symlink to make other things happier
# the jenkins config relies on a simple /opt/maven symlink to whatever version of mave is installed
# easy to type, easy to implement
  file{ "/opt/maven":
    ensure  => link,
    target  => "/opt/apache-maven-${maven_version}",
    require => Class['java'],
  }
}