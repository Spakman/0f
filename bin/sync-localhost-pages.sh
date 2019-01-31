#!/bin/sh

domain=${1}
deletes_file=/run/0f/${domain}/log/deletes

# down
rsync --exclude-from ${deletes_file} --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" ${domain}@${domain}:./${domain}/pages/ /run/0f/${domain}/pages/ &&

echo "" > ${deletes_file} &&

# up
rsync --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" /run/0f/${domain}/pages/ ${domain}@${domain}:./${domain}/pages/

