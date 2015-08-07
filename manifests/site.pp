# we want all firewall resources purged, so only the puppet ones apply
resources { "firewall":
  purge => true
}

Firewall {
  before  => Class['base::fw_post'],
  require => Class['base::fw_pre'],
}

# puppetmaster node
node 'puppetmaster.c.hd-build.internal' {
  include base
  include puppet_master
}

node 'jenkins-master.c.hd-build.internal' {
  include base
  include hd_jenkins::master

# jenkins needs to send emails too
  include base::mail_sender
}

node 'gitlab.c.hd-build.internal' {
  include base
  include hd_gitlab
}

node 'mumble.c.hd-build.internal' {
  include base
  include mumble_server
}

node 'nagios.c.hd-build.internal' {
  include base
  include hd_nagios::server
}