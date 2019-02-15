#!/bin/sh

domain=${1}
excludes_file=/data/${domain}/log/sync-excludes

# down
rsync -i --exclude-from /data/fingers.today/log/sync-excludes --delete -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" fingers.today@fingers.today:./fingers.today/pages/ /data/fingers.today/pages/ | grep -E "^>.* " | sed -e "s@^>.* @/@" &&

echo "" > ${excludes_file} &&

# up
rsync --delete -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" /data/${domain}/pages/ ${domain}@${domain}:./${domain}/pages/
