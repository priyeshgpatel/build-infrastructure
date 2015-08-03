# Actually installs jenkins, rather than waiting for the master to push the JAR
# Using installed will not automatically update jenkins for us, just make sure it's actually there.
# Since the apt-repo doesn't keep around older versions it makes for a mess, using installed will keep puppet from
# doing silly things
class hd_jenkins::master(
  $jenkins_web_hostname = $fqdn,
  $jenkins_version = "installed",
  $scm_sync_url = undef
) {
  include hd_jenkins

  $jenkins_home = '/var/lib/jenkins'


# This is kind of nasty hax.
# The repose-jenkins puppet module gets a little too restart happy, which causes our builds to be terminated
# every single time the puppet agent runs, that's no good.
# this takes a much larger hammer to it, by replacing the original jenkins init script with one that does nothing
# creating a second jenkins-real that is the one we actually want.
  file{ '/etc/init.d/jenkins':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0754,
    source  => 'puppet:///modules/hd_jenkins/jenkins-fake',
    require => Package['jenkins'],
    before  => Service['jenkins'],
  }

  file{ '/etc/init.d/jenkins-real':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0754,
    source  => 'puppet:///modules/hd_jenkins/jenkins-real',
    require => Package['jenkins'],
  }

  service{ 'jenkins-real':
    ensure  => running,
    enable  => true,
    require => [
      File['/etc/init.d/jenkins-real'],
      Class['jenkins'],
    ],
  }

# this class already explicitly uses the jenkins repo, so I'm not sure why versions are vanishing
# switching to the LTS version of jenkins for less irritating updates
  class{ 'jenkins':
    lts                => true,
    version            => "${jenkins_version}",
    configure_firewall => false,
    install_java       => false,
    repo               => true,
    require            => [
      Class['java'],
      File["${jenkins_home}/.gitconfig"]
    ],
    config_hash        => {
      'JENKINS_HOME' => { 'value' => "${jenkins_home}" },
      'JENKINS_USER' => { 'value' => 'jenkins' },
      'JENKINS_JAVA_OPTIONS' =>
      { 'value' => "-Djava.awt.headless=true -Xms2048m -Xmx4096m -XX:PermSize=512m -XX:MaxPermSize=1024m -XX:-UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled" }
    },
  }

#TODO: re-enable https when we have certificates
#include base::nginx::autohttps
  include base::nginx

  file{ "/etc/nginx/conf.d/jenkins.conf":
    ensure  => file,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template("hd_jenkins/nginx.conf.erb"),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

# define our jenkins SCM config sync plugin
# I think this is the only one we need, as it manages all the other configs
# the base class provides the ssh key for github.com, so it should be good to go
#TODO: need credentials for this stuff, and where to hook it up
  jenkins::plugin{ 'scm-sync-configuration':
    version         => '0.0.8',
    manage_config   => true,
    config_filename => "scm-sync-configuration.xml",
    config_content  => template("hd_jenkins/scm-sync-configuration.xml.erb"),
    require         => Class['hd_jenkins::build_tools::build_packages'],
  } ~>
  file{ "${jenkins_home}/log":
    ensure  => directory,
    mode    => 0755,
    owner   => jenkins,
    group   => jenkins,
    require => Class['jenkins'],
  } ~>
  file{ "${jenkins_home}/log/scm_sync_configuration.xml":
    ensure  => file,
    mode    => 0644,
    owner   => jenkins,
    group   => jenkins,
    source  => "puppet:///modules/hd_jenkins/scm_sync_configuration.xml",
    require => File["${jenkins_home}/log"],
  }

#TODO: giant pile of plugins
  jenkins::plugin{ 'git':
    version => '2.3.5'
  }

  jenkins::plugin{ 'sonar':
    version => '2.2'
  }

  jenkins::plugin{ 'copyartifact':
    version => '1.35'
  }

# to use the slave logic that the jenkins puppet module uses, we need the swarm plugin
  jenkins::plugin{ 'swarm':
    version => '1.22',
  }

# Need to have this to be able to mask passwords from the jenkins output
  jenkins::plugin { 'mask-passwords':
    version => '2.7.2'
  }
}
