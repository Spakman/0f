#!/data/data/com.termux/files/usr/bin/sh

domain=${1}

$HOME/${domain}/bin/sync-android-pages.sh ${domain} &&

rsync -u -a -v -X -e "ssh -p3237 -i $HOME/.ssh/fingers.today_id_rsa" ${domain}@${domain}:./${domain}/ $HOME/${domain}/

pkill -9 ruby

cd $HOME/${domain}/

ZEROEFF_ENV=android nohup ruby 0f.rb &
