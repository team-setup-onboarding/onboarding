#!/usr/bin/env zsh
set -Eeu -o pipefail

gh api -H "Accept: application/vnd.github+json" https://api.github.com/orgs/team-setup-onboarding/security-advisories | jq .
