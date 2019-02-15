#!/data/data/com.termux/files/usr/bin/bash

set -e

domain=${1}
excludes_file=$HOME/${domain}/log/sync-excludes

# Sync down
#
# Store output variable to ensure script exits if rsync fails (to avoid
# clearing excludes).
down_sync_output=`rsync -i --exclude-from ${excludes_file} --delete -a -u -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" ${domain}@${domain}:./${domain}/pages/ $HOME/${domain}/pages/`

echo "${down_sync_output}" | grep -E "^>.* " | sed -e "s@^>.* @/@"

echo "" > ${excludes_file}

# Sync up
rsync --delete -a -u -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" $HOME/${domain}/pages/ ${domain}@${domain}:./${domain}/pages/
