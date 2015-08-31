# Jenkins
Using the upstream jenkins puppet module, with caveats mentioned in the puppet manifest files.
This provides the manifests for a jenkins box and jenkins slaves.

Jenkins has a great deal of state in the jenkins home directory. All the job build information and build history
resides there.

There is some backups in the form of the [scm-configuration-sync plugin](https://wiki.jenkins-ci.org/display/JENKINS/SCM+Sync+configuration+plugin).
This provides a git repository containing users, jobs, and the jenkins configuration. It will not restore plugins, or
job data. It restores the configuration as it was saved. With a bit more manual work, after installing the plugins,
or making sure the puppet system manages all the plugins, this can restore the jenkins box to a working state.
Does not retain any build history though.