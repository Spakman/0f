#!/bin/sh

domain=${1}
excludes_file=/data/${domain}/log/sync-excludes

# down
rsync --exclude-from ${excludes_file} --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" ${domain}@${domain}:./${domain}/pages/ /data/${domain}/pages/ &&

echo "" > ${excludes_file} &&

# up
rsync --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" /data/${domain}/pages/ ${domain}@${domain}:./${domain}/pages/
