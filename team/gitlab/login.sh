#!/usr/bin/env zsh

set -eo pipefail

source $TEAM_HOME/onboarding/sh/formatting.sh

if [[ -z "$(team g _g)" ]];then
  echo "paste your gitlab api token"
  read -s super_secret_password
  OSTYPE=`uname -s`
  if [[ ${OSTYPE} == "Linux" ]]
  then
    keyctl add user team_gitlab_api_token "$super_secret_password" @u > /dev/null
  else
    security add-generic-password -a ${USER} -s team_gitlab_api_token -w "$super_secret_password"  > /dev/null >&2
  fi
  echo "$GREEN you are now logged in$NC" >&2
else
    echo "$RED you are already logged in, logout first$NC" >&2
fi
