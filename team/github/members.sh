 #!/usr/bin/env bash
set -Eeu -o pipefail

key=""
if [[ $# -gt 0 ]]; then

    key="$1"

fi

case $key in
    -short)
    gh api -H "Accept: application/vnd.github+json" https://api.github.com/orgs/team-setup-onboarding/members | jq -r .[].login
    ;;

    *)
    gh api -H "Accept: application/vnd.github+json" https://api.github.com/orgs/team-setup-onboarding/members | jq '.'
    ;;

esac

