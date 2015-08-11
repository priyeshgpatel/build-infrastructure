class hd_go_cd::package {
  include hd_java::oracle_jdk_8

  include apt

  apt::source { 'gocd':
    comment  => 'go.cd repository',
    location => 'http://dl.bintray.com/gocd/gocd-deb/',
    release  => '/',
    repos    => '',
    key      => {
      'id'     => '9A439A18CBD07C3FF81BCE759149B0A6173454C7',
      'source' => "https://bintray.com/user/downloadSubjectPublicKey?username=gocd"
    },
    include  => {
      'src' => false,
      'deb' => true,
    },
  }

}