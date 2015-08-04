# Installs base layer, but no jenkins itself. Perfect for a slave configuration.
# also used by the master, basically anything that wants to run our jenkins jobs
class hd_jenkins(
  $jenkins_key = undef,
  $jenkins_key_pub = undef
) {

# class to ensure jenkins is installed
# this will default to gradle 2.1, have to use a different syntax to get it with other versions
# or set the values in hiera
  include hd_jenkins::build_tools::gradle
  include hd_jenkins::build_tools::maven

# include packages that plugins might need to do work (rpm, other system packages that your build might need)
  include hd_jenkins::plugin_packages

  $jenkins_home = '/var/lib/jenkins'

  include hd_java::oracle_jdk_8
# this should be the right java, and it's already installed
  class{ 'java':
    distribution => 'jdk',
    package      => 'oracle-java8-installer',
    version      => 'present',
    require      => Class['hd_java::oracle_jdk_8'],
  }


#jenkins master needs a git config so that it can talk to the scm plugin
# Also needed by any of the release builds for when they do a git push
  file{ "${jenkins_home}/.gitconfig":
    ensure => file,
    mode   => 0664,
    owner  => jenkins,
    group  => jenkins,
    source => "puppet:///modules/hd_jenkins/jenkins-gitconfig",
  }

  group { 'jenkins':
    ensure => present,
  } ~>
  user { 'jenkins':
    ensure     => present,
    gid        => 'jenkins',
    home       => $jenkins_home,
    shell      => '/bin/bash',
    managehome => true,
  } ~>
  # Jenkins ssh key bits - for machine account, or deploy key
  file { "${jenkins_home}/.ssh":
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    mode    => '0700',
  } ~>
  file{ "${jenkins_home}/.ssh/id_rsa":
    ensure  => file,
    mode    => 0600,
    owner   => jenkins,
    group   => jenkins,
    content => "${jenkins_key}",
    require => File["${jenkins_home}/.ssh"],
  } ~>
  file{ "${jenkins_home}/.ssh/id_rsa.pub":
    mode    => 0600,
    owner   => jenkins,
    group   => jenkins,
    content => "${jenkins_key_pub}",
    require => File["${jenkins_home}/.ssh"],
  }

# Jenkins user specific tool directory info. Kinda out of place, but it fits
  file { ["${jenkins_home}/.m2", "${jenkins_home}/.gradle", "${jenkins_home}/plugins"]:
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    mode    => '0755',
    require => User['jenkins']
  } ~>
  file{ "${jenkins_home}/.m2/settings.xml":
    mode    => 0600,
    owner   => jenkins,
    group   => jenkins,
    content => template("hd_jenkins/m2settings.xml.erb"),
    require => File["${jenkins_home}/.m2"]
  }
}
