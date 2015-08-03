class hd_jenkins::build_tools::build_packages {
#Although some of it is needed on all the jenkins, not just master (still different .pp)
# if plugins need packages to be on the build hosts, here's the place to put them
# anything that's going to run jenkins stuff will need rpm
#  package { 'rpm':
#  # I don't think we care about the version here...
#    ensure => present,
#  }
#
#  package { 'expect':
#  # This is needed by the rpm-maven-plugin
#    ensure => present,
#  }
#
#  package { 'dpkg-sig':
#  # This is needed by the jdeb maven plugin
#    ensure => present,
#  }
#
  # all of the build processes need git (git is also needed in other places...)
  package { 'git':
    ensure => present,
  }

}