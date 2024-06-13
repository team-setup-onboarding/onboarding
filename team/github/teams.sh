#!/usr/bin/env bash
set -Eeu -o pipefail

key=""
if [[ $# -gt 0 ]]; then

    key="$1"

fi

case $key in
    -short)
    curl -SsL -H "Authorization: token ${GHPAT}" https://api.github.com/orgs/team-setup-onboarding/teams | jq -r .[].name
    ;;

    *)
    curl -SsL -H "Authorization: token ${GHPAT}" https://api.github.com/orgs/team-setup-onboarding/teams | jq '.'
    ;;

esac
