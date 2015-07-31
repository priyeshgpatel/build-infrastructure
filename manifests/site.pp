# we want all firewall resources purged, so only the puppet ones apply
resources { "firewall":
  purge => true
}

Firewall {
  before  => Class['base::fw_post'],
  require => Class['base::fw_pre'],
}

# puppetmaster node
node 'test-puppetmaster.c.hd-build.internal' {
  include base
  include puppet_master
}