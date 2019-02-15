#!/data/data/com.termux/files/usr/bin/sh

domain=${1}
excludes_file=$HOME/${domain}/log/sync-excludes

# down
rsync -i --exclude-from ${excludes_file} --delete -a -u -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" ${domain}@${domain}:./${domain}/pages/ $HOME/${domain}/pages/ | grep -E "^>.* " | sed -e "s@^>.* @/@" &&

echo "" > ${excludes_file} &&

# up
rsync --delete -a -u -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" $HOME/${domain}/pages/ ${domain}@${domain}:./${domain}/pages/
