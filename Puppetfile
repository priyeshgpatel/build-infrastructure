forge "https://forgeapi.puppetlabs.com"

# Just about everything uses apt
mod 'puppetlabs/apt', '2.1.1'

# many modules need firewall, so we can just include it here
mod 'puppetlabs/firewall', '1.7.0'

mod "thd/base",
  :path => "myModules/base"

mod "thd/ssl_cert",
  :path => "myModules/ssl_cert"

mod "thd/puppet_master",
  :path => "myModules/puppet_master"

mod "thd/hd_java",
  :path => "myModules/hd_java"

mod "thd/hd_gitlab",
  :path => "myModules/hd_gitlab"

#I'm like 5 mads right now, this module depends on versions of stuff I'm using. Not happy
mod "thd/hd_jenkins",
  :path => "myModules/hd_jenkins"

# using master of the module right now, because it's got updated apt support in it
mod 'rtyler/jenkins',
  :git => 'https://github.com/jenkinsci/puppet-jenkins.git',
  :ref => 'master'

mod "thd/mumble_server",
  :path => "myModules/mumble_server"

mod "thd/hd_nagios",
  :path => "myModules/hd_nagios"