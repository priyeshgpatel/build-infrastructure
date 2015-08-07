class hd_sonar::database(
  $mysql_root_password = undef,
  $mysql_backup_password = undef
) {

  include ssl_cert

  firewall{ '110 mysql access':
    port   => [3306],
    proto  => tcp,
    action => accept,
  }

  user{ 'mysql':
    ensure  => present,
    groups  => "ssl-keys",
    require => [
      Class['ssl_cert'],
      Package['mysql-server'],
    ],
  }

# have to set up the mysql database now
  class { '::mysql::server':
    root_password    => $mysql_root_password,
    override_options => {
      "mysqld" => {
        "bind-address" => "0.0.0.0",
        "ssl" => "true",
        "ssl-capath" => "/etc/ssl/certs",
        "ssl-cert" => "/etc/ssl/certs/build.gc.hdtechlab.com.crt",
        "ssl-key" => "/etc/ssl/keys/build.gc.hdtechlab.com.key"
      }
    },
    require          => Class['ssl_cert'],
  }

  mysql_database{ 'sonar':
    ensure  => present,
    charset => 'utf8',
    collate => 'utf8_general_ci',
  }

  $sonar_jdbc = hiera('hd_sonar::sonar_jdbc')
  $sonar_pass = $sonar_jdbc['password']

  mysql_user{ 'sonar@%':
    ensure        => 'present',
    password_hash => mysql_password($sonar_pass),
  }

  mysql_grant{ 'sonar@%/sonar.*':
    privileges => ['ALL'],
    table      => 'sonar.*',
    user       => 'sonar@%',
  }

#establish a backup script for stuff to dump it into /srv/mysql-backups
# set the cron time to 5 am, as nightly runs will hopefully be finished by then
# this only dumps the databases, I need to set up the backup cloud files to further archive this dir
  class { '::mysql::server::backup':
    backupuser      => 'mysql_backup',
    backuppassword  => $mysql_backup_password,
    backupdir       => '/srv/mysql-backups',
    backupdatabases => ['sonar'],
    time            => ['5', '0'],
  }


  # TODO: offserver backups
}