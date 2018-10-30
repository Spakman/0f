#!/bin/sh

# strip trailing slash
base_dir=${1%/}
domain=$2
site_path=${base_dir}/sites/${domain}

fingerprint_files() {
  files_to_fingerprint=$(find public/{css,fonts,img,js}/* -type f)
  filename_glob_to_replace={views/,public/css/}

  for filename in $files_to_fingerprint
  do
    echo "Fingerprinting ${filename}"

    fingerprint=$(sha256sum $filename | awk '{print $1}')
    new_filename=$(echo $filename | awk -F . '{print $1 ".'"$fingerprint".'" $2}')
    old_pathname=$(echo $filename | sed -e "s@public/@/@g")
    new_pathname=$(echo $new_filename | sed -e "s@public/@/@g")

    # TODO: figure out how to make {} args a variable here --> weather is too nice for doing that now :-)
    files_to_rewrite=$(grep -rl "\"$old_pathname\"" {views/,public/css/})
    for file in $files_to_rewrite
    do
      echo "Rewriting ${file}"
      mkdir -p $(dirname ${file})
      sed -i -e "s@\"${old_pathname}\"@\"${new_pathname}\"@g" $file
    done

    mkdir -p $(dirname ${new_filename})
    cp $filename ${new_filename}
  done
}

if [ -z "$domain" ]; then
  echo "Usage: fingerprint.sh <0f base dir> <domain>"
else
  rm -rf ${site_path}/assets/*
  /bin/systemctl stop 0f@${domain}.service &&
  mount -t overlay overlay -o index=off,upperdir=${site_path}/assets/,lowerdir=${site_path}/lib/:${base_dir}/lib/,workdir=${site_path}/mnt/workdir-install/ ${site_path}/mnt/install/ &&
  cd ${site_path}/mnt/install/ &&
  fingerprint_files &&
  chown -R ${domain}:${domain} ${site_path}/assets/ &&
  umount -l ${site_path}/mnt/install/ &&
  sleep 1 &&
  /bin/systemctl start 0f@${domain}.service &&
  echo "Fingerprinting assets complete"
fi
