class hd_java::import_cacert(
  $cacert_store = "/usr/lib/jvm/java-8-oracle/jre/lib/security/cacerts",
  $cacert_file = "/etc/ssl/certs/hdTechLabRoot.crt",
  $keystore_password = "changeit"
){

# Must have the SSL cert on the system first
  include ssl_cert

  java_ks{ 'hdtechlabroot':
    certificate => $cacert_file,
    ensure      => present,
    path        => ['/usr/bin/'],
    password    => $keystore_password,
    target      => $cacert_store,
  }
}