#!/usr/bin/env zsh

set -eo pipefail

if [ "$#" -lt 2 ]
then
  echo "$0 create-config <config_name> <gcloud_email>"
  exit 1
fi

config_name=$1
gcloud_email=$2

gcloud config configurations create "$config_name"
export CLOUDSDK_ACTIVE_CONFIG_NAME="$config_name"
gcloud config set core/account "$gcloud_email"
echo 'export CLOUDSDK_ACTIVE_CONFIG_NAME="'$config_name'"' >> .envrc
