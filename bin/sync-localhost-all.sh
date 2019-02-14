#!/bin/sh

domain=${1}

/data/${domain}/bin/sync-localhost-pages.sh ${domain} &&

rsync -u -a -v -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" ${domain}@${domain}:./${domain}/ /data/${domain}/

sudo /usr/bin/systemctl restart 0f@${domain}.service
