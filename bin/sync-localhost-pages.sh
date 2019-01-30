#!/bin/sh

domain=${1}
deletes_file=/run/0f/${domain}/log/deletes

rsync --exclude-from ${deletes_file} --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" ${domain}@${domain}:./sites/${domain}/pages/ /data/0f/sites/${domain}/pages/ &&

echo "" > ${deletes_file} &&

rsync --delete -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" /data/0f/sites/${domain}/pages/ ${domain}@${domain}:./sites/${domain}/pages/
