#!/data/data/com.termux/files/usr/bin/bash

domain=${1}
root=${HOME}/${domain}
excludes_file=${root}/log/sync-excludes


# Snapshot pages before syncing anything, just in case
cd ${root}/pages/
mv ${root}/pages.git/ .git
mv ${root}/log/pages.metadata .

find . -print0 | xargs -0 getfattr -d > pages.metadata && git add -A && git commit -a -q -m '    Automated snapshot' > /dev/null

mv .git/ ../pages.git
mv pages.metadata ../log/


set -e

# Sync down
#
# Store output variable to ensure script exits if rsync fails (to avoid
# clearing excludes).
down_sync_output=`rsync -i --exclude-from ${excludes_file} --delete -a -u -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" ${domain}@${domain}:./${domain}/pages/ ${root}/pages/`

# Output for 0f
echo "${down_sync_output}" | grep -E "^>.* " | sed -e "s@^>.* @/@"

# Clear excludes
echo "" > ${excludes_file}

# Sync up
rsync --delete -a -u -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" ${root}/pages/ ${domain}@${domain}:./${domain}/pages/
