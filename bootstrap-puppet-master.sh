#!/bin/bash

# bootstrap script for the puppetserver for debian 7 and puppet 3.x
# Not going to use puppet 4, because 3.x is simpler, and we can move to chef

# Testing for root, so that I can do all the things
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi &&

wget https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb &&
dpkg -i puppetlabs-release-wheezy.deb
apt-get update

# install the stuff
apt-get install -y git ruby1.9.1-dev make puppetmaster-passenger &&

if [[ "$(facter fqdn)" == "" ]]; then
  echo "UNABLE TO PROCEED, puppet cannot find a hostname, ensure `facter fqdn` returns a hostname"
  echo "CentOS Reference: http://www.rackspace.com/knowledge_center/article/centos-hostname-change"
  echo "Debian Reference: https://wiki.debian.org/HowTo/ChangeHostname"
  exit 1
fi &&

cd /srv &&
git clone https://github.com/homedepotlabs/build-infrastructure.git puppet &&

#Using this to manage our puppet modules
echo "Installing librarian-puppet and bundler" &&
gem install bundler librarian-puppet --no-rdoc --no-ri &&

# Clean up some stuff for /etc/puppet work
cd /etc/puppet &&
mkdir -p ssl &&
#ensure links are clean
rm -rf /etc/puppet/modules     &&
rm -rf /etc/puppet/hiera.yaml  &&
rm -rf /etc/puppet/hieradata   &&
rm -rf /etc/puppet/manifests   &&
rm -rf /etc/puppet/puppet.conf &&

# create symlinks into the git repo's data
ln -s /srv/puppet/modules     &&
ln -s /srv/puppet/hiera.yaml  &&
ln -s /srv/puppet/hieradata   &&
ln -s /srv/puppet/manifests   &&
ln -s /srv/puppet/puppet.conf &&
# I think also it uses /etc/hiera.yaml
ln -sf /srv/puppet/hiera.yaml /etc/hiera.yaml &&

# go ahead and actually install the modules
cd /srv/puppet &&
librarian-puppet install &&
echo "PREP DONE! Last steps:"
echo "For encrypted secrets, put the eyaml backend cert and key onto this system"
echo "at  /etc/puppet/ssl/private_key.pkcs7.pem"
echo "and /etc/puppet/ssl/public_key.pkcs7.pem"
echo "run puppet master --no-daemonize --verbose one time to generate the SSL certs it needs"
echo "kill it after a few moments, so it's generated the ssl certs"
echo "then run puppet apply /etc/puppet/manifests/puppet_master.pp"