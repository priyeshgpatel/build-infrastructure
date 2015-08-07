class hd_nagios::client {

    include hd_nagios
# this class is for things that aren't going to run nagios directly, but will probably run nrpe
    package { 'nagios-nrpe-server':
        ensure => present,
    }

# add a firewall rule
    firewall{ '100 accept TCP 5666':
        port   => 5666,
        proto  => tcp,
        action => accept,
    }

# Bah, nrpe doesn't use /etc/nagios3
    file{ 'nrpe-config':
        path    => '/etc/nagios/nrpe_local.cfg',
        owner   => root,
        group   => root,
        mode    => 0644,
        source  => 'puppet:///modules/hd_nagios/client_nrpe.conf',
        require => Package['nagios-nrpe-server'],
        notify  => Service['nagios-nrpe-server'],
    }

    service{ 'nagios-nrpe-server':
        ensure  => running,
        enable  => true,
        require => [
            Package['nagios-nrpe-server'],
            File['nrpe-config']
        ],
    }
}