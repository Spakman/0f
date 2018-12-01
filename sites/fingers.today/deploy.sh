#!/bin/sh

hostname=fingers.today
domain=fingers.today
base_dir=/data/0f/
sitepath=${base_dir}/sites/${domain}/lib/

if [ -z "$1" ]; then
  echo "Usage: deploy <gitobject>"
else
  revision_for_log=$(git rev-parse $1) &&
  git archive -o deploy.tar.gz ${revision_for_log} &&
  scp deploy.tar.gz ${hostname}:${sitepath} &&
  rm deploy.tar.gz &&
  ssh -t ${hostname} "
    cd ${sitepath} &&
    tar -zxvf deploy.tar.gz &&
    rm deploy.tar.gz &&
    sudo PATH=$PATH ${base_dir%/}/lib/bin/0f --base-dir ${base_dir} --domain ${domain} --fingerprint &&
    echo $(date): ${revision_for_log} >> deploy.log
  "
fi
