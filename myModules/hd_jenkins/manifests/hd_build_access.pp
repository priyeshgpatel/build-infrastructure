class hd_jenkins::hd_build_access(
  $svc_account = undef
) {

  include hd_jenkins

  hd_jenkins::gcloud_svc_account{ "hd-build":
    creds_json => $svc_account,
  }

}