 #!/usr/bin/env bash
set -Eeu -o pipefail

key=""
if [[ $# -gt 0 ]]; then

    key="$1"

fi

case $key in
    -short)
    curl -SsL -H "Authorization: token ${GHPAT}" https://api.github.com/orgs/team-setup-onboarding/members | jq -r .[].login
    ;;

    *)
    curl -SsL -H "Authorization: token ${GHPAT}" https://api.github.com/orgs/team-setup-onboarding/members | jq '.'
    ;;

esac

