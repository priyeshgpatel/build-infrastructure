#!/bin/bash
#!/bin/bash

# bootstrap script for the puppet agents
# Not going to use puppet 4, because 3.x is simpler, and we can move to chef

# Testing for root, so that I can do all the things
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi &&

wget https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb &&
dpkg -i puppetlabs-release-wheezy.deb &&
apt-get update &&

# install the stuff
apt-get install -y puppet  &&

echo "First run of puppet agent, which will create the cert!" &&
echo "Sign the cert on the puppet master and ship it" &&
puppet agent --test
