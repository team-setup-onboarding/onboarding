#!/usr/bin/env zsh

set -eo pipefail

source $TEAM_HOME/onboarding/sh/formatting.sh

OSTYPE=`uname -s`
if [[ ${OSTYPE} == "Linux" ]]
then
  KEY_ID=`keyctl request user team_gitlab_api_token 2> /dev/null || true`
  if [[ -n ${KEY_ID} ]]
  then
    keyctl revoke ${KEY_ID} || true
    keyctl reap > /dev/null
  fi
else
  security delete-generic-password -a ${USER} -s team_gitlab_api_token 2> /dev/null > /dev/null || true
fi
echo "$BLUE you are now logged out$NC"
