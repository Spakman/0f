#!/usr/bin/bash

set -e

domain=${1}
excludes_file=/data/${domain}/log/sync-excludes

# Sync down
#
# Store output variable to ensure script exits if rsync fails (to avoid
# clearing excludes).
down_sync_output=`rsync -i --exclude-from /data/fingers.today/log/sync-excludes --delete -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" fingers.today@fingers.today:./fingers.today/pages/ /data/fingers.today/pages/`

echo "${down_sync_output}" | grep -E "^>.* " | sed -e "s@^>.* @/@"

echo "" > ${excludes_file}

# Sync up
rsync --delete -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" /data/${domain}/pages/ ${domain}@${domain}:./${domain}/pages/
