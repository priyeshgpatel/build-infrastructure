#!/bin/bash

#ubuntu focused bootstrap script
# bootstrap script for the puppet agents
# Not going to use puppet 4, because 3.x is simpler, and we can move to chef

# Testing for root, so that I can do all the things
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi &&

wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb &&
dpkg -i puppetlabs-release-trusty.deb &&
apt-get update &&

# install the stuff
apt-get install -y puppet  &&

# Set up the puppet.conf file to point to the proper puppet master

cat <<EOF >> /etc/puppet/puppet.conf
[agent]
     server = puppetmaster.c.hd-build.internal

EOF

echo "First run of puppet agent, which will create the cert!" &&
echo "Sign the cert on the puppet master and ship it" &&
puppet agent --test
