#!/bin/sh

hostname=fingers.today
domain=fingers.today
sitepath=/data/0f/sites/${domain}/lib/

fingerprint_files() {
  files_to_fingerprint=$(find public/{css,fonts,img,js}/* -type f)
  filename_glob_to_replace="views/*.erb public/css/*.css"

  for filename in $files_to_fingerprint
  do
    fingerprint=$(sha256sum $filename | awk '{print $1}')
    new_filename=$(echo $filename | awk -F . '{print $1 ".'"$fingerprint".'" $2}')
    old_pathname=$(echo $filename | sed -e "s@public/@/@g")
    new_pathname=$(echo $new_filename | sed -e "s@public/@/@g")

    find $filename_glob_to_replace -type f -exec sed -i -e "s@\"${old_pathname}\"@\"${new_pathname}\"@g" {} \;
    mv $filename $new_filename
  done
}

if [ -z "$1" ]; then
  echo "Usage: deploy <gitobject>"
else
  revision_for_log=$(git rev-parse $1)
  git checkout -b deploy
  fingerprint_files
  git add public/* views/*
  git commit -q -m "Deploy: $(date)"
  git archive -o deploy.tar.gz HEAD
  scp deploy.tar.gz ${hostname}:${sitepath}
  rm deploy.tar.gz
  ssh -t ${hostname} "
    cd ${sitepath} &&
    tar -zxvf deploy.tar.gz &&
    rm deploy.tar.gz &&
    sudo /bin/systemctl restart 0f@${domain}.service &&
    echo $(date): ${revision_for_log} >> deploy.log
  "
  git checkout -
  git branch -D deploy
fi
