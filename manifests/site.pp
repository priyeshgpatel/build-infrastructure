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
  # for now, include the base::java module to get some java ppa options in there
  include base::java
}

node 'gitlab.c.hd-build.internal' {
  include base
  include hd_gitlab
}