# Actually installs jenkins, rather than waiting for the master to push the JAR
define hd_jenkins::slave(
  $jenkins_username = hiera("hd_jenkins::slave::jenkins_username", "nope"),
  $jenkins_password = hiera("hd_jenkins::slave::jenkins_password", "nope"),
  $master_url = hiera("hd_jenkins::slave::master_url", "nope"),
  $executors = 2,
  $jenkins_home = hiera('hd_jenkins::jenkins_home', undef),
  $labels = "",
  $description = "",
) {
  include hd_jenkins

  class{ "jenkins::slave":
    slave_name               => $name,
    masterurl                => $master_url,
    version                  => "1.15",
    ui_user                  => $jenkins_username,
    ui_pass                  => $jenkins_password,
    manage_slave_user        => false,
    slave_user               => "jenkins",
    slave_home               => $jenkins_home,
    executors                => $executors,
    disable_ssl_verification => true,
    labels                   => $labels,
    description              => $description,
  }
}