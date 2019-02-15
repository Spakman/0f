#!/data/data/com.termux/files/usr/bin/sh

domain=${1}

$HOME/${domain}/bin/sync-android-pages.sh ${domain} &&

rsync -u -a -v -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" ${domain}@${domain}:./${domain}/ $HOME/${domain}/

# sudo /usr/bin/systemctl restart 0f-localhost@${domain}.service
