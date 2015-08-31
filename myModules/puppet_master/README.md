# Puppetmaster

Has no public facing interface. Just provides puppet manifests to nodes to keep the boxes looking fresh.

`/srv/puppet` contains the git repo source, you can `git pull && librarian-puppet install` to bring it up to date with
master. After that you can kick a `puppet agent` run on any box to get the latest. There's a shell script `puppet-repo-sync.sh`
that runs every 30 minutes, but sometimes it gets stupid.