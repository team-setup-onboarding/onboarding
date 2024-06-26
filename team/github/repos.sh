#!/usr/bin/env bash
set -Eeu -o pipefail

key=""
if [[ $# -gt 0 ]]; then
    key="$1"
fi

case $key in
    -short)
    gh api -H "Accept: application/vnd.github+json" https://api.github.com/orgs/team-setup-onboarding/teams/demo-team/repos | jq '"\(.[].name)"'  | tr -d '"'
    ;;

    -http)
    gh api -H "Accept: application/vnd.github+json" https://api.github.com/orgs/team-setup-onboarding/teams/demo-team/repos | jq '"https://github.com/team-setup-onboarding/\(.[].name).git"' | tr -d '"'
    ;;

    -ssh)
    gh api -H "Accept: application/vnd.github+json" https://api.github.com/orgs/team-setup-onboarding/teams/demo-team/repos | jq '"git@github.com:team-setup-onboarding/\(.[].name).git"' | tr -d '"'
    ;;

    -json)
    gh api -H "Accept: application/vnd.github+json" https://api.github.com/orgs/team-setup-onboarding/teams/demo-team/repos | jq '. | map({ name, description: (if (.description == null) then "" else .description end), auto_init: .archived | @text, archived: .archived | @text, private: .private | @text, homepage_url: (if (.homepage == null) then "" else .homepage end), has_issues: .has_issues | @text, has_downloads: .has_downloads | @text, has_pages: .has_pages | @text, has_wiki: .has_wiki | @text})'
    ;;
    *)
        echo
        echo "<option> is one of:"
        echo "   -short : list of all repo names"
        echo "   -ssh   : all the ssh urls for cloning"
        echo "   -http  : all the http urls for cloning"
        echo "   -json  : raw json list of repos"
    ;;

esac
