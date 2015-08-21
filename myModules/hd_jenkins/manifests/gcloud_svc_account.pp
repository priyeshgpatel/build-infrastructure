define hd_jenkins::gcloud_svc_account(
  $creds_json = undef,
) {
  include hd_jenkins::gcloud_cred_storage

  $jenkins_home = hiera('hd_jenkins::jenkins_home', undef)

  file{ "${jenkins_home}/gcloud_creds/gcloud-${name}.json":
    ensure  => file,
    content => $creds_json,
    owner   => jenkins,
    group   =>  jenkins,
    mode    => 0600,
    require => File["${jenkins_home}/gcloud_creds"]
  }
}