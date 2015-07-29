define ssl_cert::certificate(
  $cert_name = undef,
  $cert_content = undef,
  $key_content = undef
) {

  include ssl_cert::rehash_certs
  include ssl_cert::key_dir

  if($cert_content == undef) {
    fail("$cert_name certificate content cannot be undefined")
  }

  if($key_content == undef) {
    info("$cert_name key content is undefined")
  }

  file { "/etc/ssl/certs/$cert_name.crt":
    ensure  => present,
    content => $cert_content,
    owner   => root,
    group   => root,
    mode    => 0444,
  }

  file { "/etc/ssl/certs/$cert_name.pem":
    ensure  => link,
    target  => "/etc/ssl/certs/$cert_name.crt",
    require => File["/etc/ssl/certs/$cert_name.crt"],
    notify  => Exec["rehash_certs"],
  }

  if($key_content != undef) {
    file { "/etc/ssl/private/$cert_name.key":
      ensure  => present,
      content => $key_content,
      owner   => root,
      group   => root,
      mode    => 0440,
    }

    file{ "/etc/ssl/keys/${cert_name}.key":
      ensure  => present,
      content => $key_content,
      owner   => root,
      group   => ssl-keys,
      mode    => 0440,
      require => [
        File['/etc/ssl/keys'],
        Group['ssl-keys']
      ],
    }
  }

}