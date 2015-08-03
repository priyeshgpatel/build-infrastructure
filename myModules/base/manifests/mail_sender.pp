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
# using sendgrid as the relay host

  package{ 'postfix':
    ensure => present,
  }

  package{ 'libsasl2-modules':
    ensure => present,
  }

  service{ 'postfix':
    ensure  => running,
    enable  => true,
    require => Package['postfix', 'libsasl2-modules'],
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
    command     => '/usr/sbin/postmap /etc/postfix/sasl_password',
    refreshonly => true,
    notify      => Service['postfix'],
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