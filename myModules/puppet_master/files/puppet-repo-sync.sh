#!/bin/bash

## MANAGED BY PUPPET
#This script is managed by puppet and is specific to how the puppet master is set up.
# /srv/puppet contains the git repo that runs all the puppets
# This script is designed to be run periodically from cron

pushd /srv/puppet 2>&1 > /dev/null &&


# Just always do the work, because it's not worth the effort if it fails
# Go ahead and pull the repo and update the modules
# capture the output, in case something fails
TEMP_FILE=`mktemp`
git pull -q 2>&1 > ${TEMP_FILE}
librarian-puppet install 2>&1 >> ${TEMP_FILE} || cat ${TEMP_FILE}

#Clean up our temp file now that we've cat it (if we needed to)
rm ${TEMP_FILE}
