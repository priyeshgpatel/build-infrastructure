# we want all firewall resources purged, so only the puppet ones apply
resources { "firewall":
  purge => true
}

Firewall {
  before  => Class['base::fw_post'],
  require => Class['base::fw_pre'],
}

node default {
  include base
}

# puppetmaster node
node 'puppetmaster.c.hd-build.internal' {
  include base
  include puppet_master
  include hd_nagios::client
}

node 'jenkins-master.c.hd-build.internal' {
  include base
  include hd_jenkins::master
  # I want the master to build java projects for me
  include hd_jenkins::java_builder

# jenkins needs to send emails too
  include base::mail_sender
  include hd_nagios::client
}

node 'gitlab.c.hd-build.internal' {
  include base
  include hd_gitlab
  include hd_nagios::client
}

node 'mumble.c.hd-build.internal' {
  include base
  include mumble_server
  include hd_nagios::client
}

node 'nagios.c.hd-build.internal' {
  include base
  include hd_nagios::server
  include hd_nagios::client
}

node 'sonar.c.hd-build.internal' {
  include base
  include hd_nagios::client
  include hd_sonar
}

node 'artifactory.c.hd-build.internal' {
  include base
  include hd_nagios::client
  include hd_artifactory
}

node "dkowis-ubuntu-puppets.c.hd-build.internal" {
  include base
}