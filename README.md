## Using puppet modules from the forge

Check the Puppetfile for any notes on them, and which modules are in use

## Using librarian-puppet to manage dependencies
r10k doesn't handle dependencies in `Modulefiles`. 

## Using hiera-eyaml for encryption

Guide: https://github.com/TomPoulton/hiera-eyaml#configuration-file-for-eyaml


## Useful References
* http://ttboj.wordpress.com/2013/02/20/automatic-hiera-lookups-in-puppet-3-x/
* http://librarian-puppet.com/
* https://forge.puppetlabs.com/puppetlabs/firewall

## TODO LIST
- [ ] SSL Root cert needs to be added to the JDK: [see this](https://azure.microsoft.com/en-us/documentation/articles/java-add-certificate-ca-store/)
- [ ] Sonar Secrets file needs to be added to anything that's going to run the analysis
