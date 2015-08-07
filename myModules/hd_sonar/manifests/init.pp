class hd_sonar(
  $sonar_jdbc = undef
) {

  include hd_sonar::database

  include hd_java::oracle_jdk_8

  if($sonar_jdbc == undef) {
    fail("Must have sonar's JDBC configured")
  }

  class{ 'sonarqube':
    version     => '5.1.2',
    user        => 'sonar',
    group       => 'sonar',
    service     => 'sonar',
    installroot => '/opt',
    home        => '/opt/sonar-work',
    jdbc        => $sonar_jdbc,
    require     => [
      Class['maven::maven'],
      Class['hd_sonar::database']
    ],
  }

  sonarqube::plugin{ 'sonar-scm-activity':
    groupid    => 'org.codehaus.sonar-plugins.scm-activity',
    artifactid => 'sonar-scm-activity-plugin',
    version    => '1.8',
    notify     => Service['sonar'],
  }

  sonarqube::plugin{ 'sonar-scm-stats-plugin':
    groupid    => 'org.codehaus.sonar-plugins',
    artifactid => 'sonar-scm-stats-plugin',
    version    => '0.3.1',
    notify     => Service['sonar'],
  }

  sonarqube::plugin{ 'sonar-tab-metrics-plugin':
    groupid    => 'org.codehaus.sonar-plugins',
    artifactid => 'sonar-tab-metrics-plugin',
    version    => '1.4.1',
    notify     => Service['sonar'],
  }

  sonarqube::plugin{ 'sonar-findbugs-plugin':
    groupid    => 'org.codehaus.sonar.plugins',
    artifactid => 'sonar-findbugs-plugin',
    version    => '3.3.2',
    notify     => Service['sonar'],
  }

  include base::nginx::autohttps

  file{ "/etc/nginx/conf.d/sonar.conf":
    ensure  => file,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template("hd_sonar/nginx.conf.erb"),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
}