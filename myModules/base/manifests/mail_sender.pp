class base::mail_sender(
  $sendgrid_user = undef,
  $sendgrid_pass = undef
) {
  include ssl_cert

  if $sendgrid_user == undef {
    fail("Sendgrid User must be configured")
  }

  if($sendgrid_pass == undef) {
    fail("Sendgrid Password must be configured")
  }


# this is just a class to handle a sending-only postfix server
# it cannot receive, and it will only handle sending outgoing mail
# It's also special for the google cloud, requiring sendgrid credentials

  package{ 'postfix':
    ensure => present,
  }

  service{ 'postfix':
    ensure  => running,
    enable  => true,
    require => Package['postfix'],
  }

  file{ '/etc/postfix/sasl_password':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0640,
    content => template('base/postfix/sasl_password.erb'),
    require => [
      Package['postfix']
    ],
    notify  => Exec['PostmapSASL'],
  }

  exec{ 'PostmapSASL':
    command     => '/usr/bin/postmap /etc/postfix/sasl_password',
    refreshonly => true,
  }

  file{ '/etc/postfix/main.cf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template('base/postfix/local-only-main.cf.erb'),
    require => [
      File['/etc/postfix/sasl_password'],
      Package['postfix'],
      Class['ssl_cert']
    ],
    notify  => Service['postfix'],
  }

}