# Puppet!
Using puppet 3.8 series, since it was the shortest path to success. Puppet 4.0 is the latest at time of writing.

## Using puppet modules from the forge
Check the Puppetfile for any notes on them, and which modules are in use

## Using librarian-puppet to manage dependencies
r10k doesn't handle dependencies in `Modulefiles`. librarian-puppet is a bit simpler, and does handle chained
dependencies.

## Using hiera-eyaml for encryption
Storing secrets using hiera-eyaml. Guide: https://github.com/TomPoulton/hiera-eyaml#configuration-file-for-eyaml

## Useful References
* http://ttboj.wordpress.com/2013/02/20/automatic-hiera-lookups-in-puppet-3-x/
* http://librarian-puppet.com/
* https://forge.puppetlabs.com/puppetlabs/firewall

# More detailed information

## Building a new box
You will need to fire off one of the bootstrap scripts on the machine, once it is created. Use a bootstrap script
tailored to the distro you're using. As of this commit, this repo supports Debian Wheezy 7 and Ubuntu LTS 14.04.
After doing that, since auto signing is not (yet) configured on the puppet master, you will need to log into the puppet 
master and sign the certificate for the box you've just created. Then re-run the puppet agent on the fresh box, and it
will get the default settings, unless its hostname matches something in site.pp.

Puppet is not guaranteed to restore everything to completely the way it was before, as the applications running on the
boxes puppet creates have their own state. 

Standard puppet procedures apply.
