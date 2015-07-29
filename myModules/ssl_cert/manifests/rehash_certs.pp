class ssl_cert::rehash_certs {
# located in this class to be referenced in multiple files, and only trigger one rehash of certs, if we need to dump
# many certs on a host
  exec { "rehash_certs":
    command     => "/usr/bin/c_rehash /etc/ssl/certs",
    refreshonly => true,
  }
}