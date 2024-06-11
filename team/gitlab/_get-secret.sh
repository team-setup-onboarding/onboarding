#!/usr/bin/env zsh

set -eo pipefail

source $TEAM_HOME/onboarding/sh/formatting.sh

OSTYPE=`uname -s`
if [[ ${OSTYPE} == "Linux" ]]
then
  KEY_ID=`keyctl request user team_gitlab_api_token 2> /dev/null || true`
  if [[ -n ${KEY_ID} ]]
  then
    keyctl print ${KEY_ID}
  fi
else
  security find-generic-password -a ${USER} -s team_gitlab_api_token -w 2> /dev/null || echo "$RED you are not logged in$NC" >&2
fi
