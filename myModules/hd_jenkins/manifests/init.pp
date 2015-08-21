# Installs base layer, but no jenkins itself. Perfect for a slave configuration.
# also used by the master, basically anything that wants to run our jenkins jobs
class hd_jenkins(
  $jenkins_home = hiera('hd_jenkins::jenkins_home', undef),
  $jenkins_key = undef,
  $jenkins_key_pub = undef
) {

# include packages that plugins might need to do work (rpm, other system packages that your build might need)
  include hd_jenkins::build_tools::build_packages

# ensure we have a java installed
  include hd_java::oracle_jdk_8

# also need to include the root cert in the oracle keystore root
  include hd_java::import_cacert

#jenkins master needs a git config so that it can talk to the scm plugin
# Also needed by any of the release builds for when they do a git push
  file{ "${jenkins_home}/.gitconfig":
    ensure  => file,
    mode    => 0664,
    owner   => jenkins,
    group   => jenkins,
    source  => "puppet:///modules/hd_jenkins/jenkins-gitconfig",
    require => User["jenkins"],
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

# specify knowledge of host keys, so that ssh's from a jenkins host to another, work fine!
  $github_key_info = hiera_hash("host_keys::github_host_key", { "key" => "DEFAULT", "type" => "ssh-rsa" })
  $gitlab_key_info = hiera_hash("host_keys::gitlab_host_key", { "key" => "DEFAULT", "type" => "ssh-rsa" })

  sshkey{ 'github.com':
    ensure => present,
    name   => $github_key_info["name"],
    key    => $github_key_info["key"],
    type   => $github_key_info["type"],
  }

  sshkey{ 'gitlab.build.gc.hdtechlab.com':
    ensure => present,
    name   => $gitlab_key_info['name'],
    key    => $gitlab_key_info['key'],
    type   => $gitlab_key_info['type'],
  }

#https://tickets.puppetlabs.com/browse/PUP-1177
# turns out puppet creates this file rather stupidly.
  file{ "/etc/ssh/ssh_known_hosts":
    ensure  => file,
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Sshkey["github.com"],
  }


}
