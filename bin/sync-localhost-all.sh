#!/bin/sh

domain=${1}

/data/${domain}/bin/sync-localhost-pages.sh ${domain} &&

rsync --exclude /log/pages.metadata -u -a -v -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" ${domain}@${domain}:./${domain}/ /data/${domain}/

sudo /usr/bin/systemctl restart 0f-localhost@${domain}.service
