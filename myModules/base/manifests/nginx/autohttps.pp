class base::nginx::autohttps{
  include base::nginx

  $template_fqdn = hiera('external_fqdn', $fqdn)

  file{ '/etc/nginx/conf.d/00-https-redirect.conf':
    ensure  => file,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => template('base/nginx/https-redirect.conf.erb'),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

}