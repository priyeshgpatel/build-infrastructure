class hd_jenkins::builders::java(
  $jenkins_home = hiera('hd_jenkins::jenkins_home', undef),
  $sonar_secret = undef
) {
# not all jenkins machines will need this stuff....
# this will default to gradle 2.1, have to use a different syntax to get it with other versions
# or set the values in hiera
  include hd_jenkins::build_tools::gradle
  include hd_jenkins::build_tools::maven

# need to have the HD jenkins stuff first
  include hd_jenkins
#TODO: put other stuff in here that's java building specific

# sonar secret key stuff for doing sonar analysis
  file{ "${jenkins_home}/.sonar":
    ensure  => directory,
    owner   => jenkins,
    group   => jenkins,
    mode    => 0700,
    require => Class['hd_jenkins'],
  } ~>
  file{ "${jenkins_home}/.sonar/sonar-secret.txt":
    ensure  => file,
    owner   => jenkins,
    group   => jenkins,
    mode    => 0700,
    content => $sonar_secret,
  }
}