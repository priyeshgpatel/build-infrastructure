class hd_jenkins::gcloud_cred_storage(
  $jenkins_home = hiera('hd_jenkins::jenkins_home', undef)
) {

  include hd_jenkins

  file{ "${jenkins_home}/gcloud_creds":
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    mode    => 0700,
    require => User['jenkins'],
  }
}