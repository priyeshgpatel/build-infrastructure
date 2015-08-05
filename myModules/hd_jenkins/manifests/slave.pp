# Actually installs jenkins, rather than waiting for the master to push the JAR
class hd_jenkins::slave(
  $jenkins_username = "nope",
  $jenkins_password = "nope",
  $master_url = "http://TODO.TODO.internal",
  $executors = 2,
  $jenkins_home = hiera('hd_jenkins::jenkins_home', undef),
) {
  include hd_jenkins

  class{ 'jenkins::slave':
    masterurl         => $master_url,
    version           => "1.15",
    ui_user           => $jenkins_username,
    ui_password       => $jenkins_password,
    manage_slave_user => 0,
    slave_user        => "jenkins",
    slave_home        => $jenkins_home,
    executors         => $executors,
  }

}