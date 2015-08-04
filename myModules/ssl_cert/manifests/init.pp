class ssl_cert(
  $ca_content = undef,
  $wildcard_cert = undef,
  $wildcard_key = undef
){

# add the root CA
  ssl_cert::certificate{ 'rootCA':
    cert_name    => "hdTechLabsRoot",
    cert_content => $ca_content,
  }

# add our wildcard key/cert for gettin bizness done
  ssl_cert::certificate{ 'wildcardCert':
    cert_name    => "build.gc.hdtechlabs.com",
    cert_content => $wildcard_cert,
    key_content  => $wildcard_key,
  }

}