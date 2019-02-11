#!/bin/sh

domain=${1}
excludes_file=/run/0f/${domain}/log/sync-excludes

# down
rsync --exclude-from ${excludes_file} --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" ${domain}@${domain}:./${domain}/pages/ /run/0f/${domain}/pages/ &&

echo "" > ${excludes_file} &&

# up
rsync --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" /run/0f/${domain}/pages/ ${domain}@${domain}:./${domain}/pages/

