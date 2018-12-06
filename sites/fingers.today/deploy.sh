#!/bin/sh

hostname=fingers.today
domain=fingers.today
base_dir=/data/0f/
site_base_dir=${base_dir}sites/${domain}/
site_lib_dir=${site_base_dir}lib/

if [ -z "$1" ]; then
  echo "Usage: deploy <gitobject>"
else
  revision_for_log=$(git rev-parse $1) &&
  git archive -o deploy.tar.gz ${revision_for_log} &&
  scp deploy.tar.gz ${hostname}:${site_lib_dir} &&
  rm deploy.tar.gz &&
  ssh -t ${hostname} "
    cd ${site_lib_dir} &&
    find ${rootpath} ! -name deploy.tar.gz ! -name lib -print -delete &&
    tar -zxvf deploy.tar.gz &&
    rm deploy.tar.gz &&
    sudo PATH=$PATH ${base_dir%/}/lib/bin/0f --base-dir ${base_dir} --domain ${domain} --fingerprint &&
    echo $(date): ${revision_for_log} >> ${site_base_dir}log/deploy.log
  "
fi
