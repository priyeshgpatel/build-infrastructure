class hd_jenkins::image_builder {
# stuff that's needed to set up a box to build images currently using packer
#packer is distributed as a zip file!
  $packer_version = "0.8.5"
  $packer_sha256 = "f0c65a11c6527d408b844d4302f27be0492f2c2a8ae92f7b8b213aad51c88ec1"

  file{ "/opt/packer-$packer_version":
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => "0755",
  } ~>
  archive{ "packer-$version":
    ensure           => present,
    url              => "https://dl.bintray.com/mitchellh/packer/packer_${packer_version}_linux_amd64.zip",
    follow_redirects => true,
    target           => "/opt/packer-$packer_version",
    extension        => "zip",
    checksum         => true,
    digest_type      => "sha256",
    digest_string    => $packer_sha256,
  } ~>
  file{ "packer-symlink":
    path   => "/opt/packer",
    ensure => link,
    target => "/opt/packer-${packer_version}}",
  }

#packer path in /etc/profile.d
  file{ "/etc/profile.d/10-packer-path.sh":
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0755,
    source => "puppet:///modules/hd_jenkins/image_builder/packer-path.sh",
  }
}