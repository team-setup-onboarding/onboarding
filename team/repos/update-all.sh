#! /usr/bin/env bash
set -eo pipefail

source $TEAM_HOME/onboarding/sh/formatting.sh

declare -a REPOS=($(team r l -short))

function pullGitRepos {
  cd ${TEAM_HOME}

  no_fetched=0
  no_pulled=0
  skipped=()
  conflicts=()
  not_cloned=()

  for repo in ${REPOS[*]}
  do
    echo
    echo "-----------------------------------------"
    echo "Checking ${repo}.."
    if [[ -d "${repo}" ]]
    then

        cd ${repo}
        git fetch --all
        no_fetched=$((no_fetched + 1))

        changed_files=$(git status -s -uno | wc -l)
        has_branches=$(git branch -a | wc -l)

        set +e
        # grep fails when no match
        has_tracked_branch=$(git branch -vv | grep "^\* \S\+\s\+\S\+ \[\w\+/\S\+]" | wc -l)
        set -e

        if (( ${changed_files} > 0 ))
        then
            echo -e "${FMT_RED}Unstashed changes, skipping.${FMT_RESET}"
            skipped+=(${repo})
        elif (( ${has_branches} < 1 ))
        then
            echo -e "${FMT_RED}Empty repo, skipping.${FMT_RESET}"
            skipped+=(${repo})
        elif (( ${has_tracked_branch} < 1 ))
        then
            echo -e "${FMT_RED}No tracked branch for '$(git name-rev --name-only HEAD)', skipping.${FMT_RESET}"
            skipped+=(${repo})
        else
            echo "pull/rebase ${repo}"
            git pull --rebase

            set +e
            git status | grep "both" #e.g. both added, both modified, etc.
            did_conflict=$?
            set -e

            if [ $did_conflict -eq 0 ]
            then
              conflicts+=(${repo})
            fi

            no_pulled=$((no_pulled + 1))
            echo -e "${FMT_GREEN}Updated${FMT_RESET}"
        fi
        cd ${TEAM_HOME}

    else
        not_cloned+=(${repo})
        echo -e "${FMT_RED}${repo} has not been cloned, consider running ${FMT_RESET}${FMT_BLUE}$> ${FMT_RESET}os repos clone ${repo}"
    fi
  done
}

pullGitRepos
echo ""
echo ""
echo -e "${FMT_BLUE}************************* SUMMARY *************************${FMT_RESET}"
echo -e " ${FMT_GREEN}${no_fetched}${FMT_RESET} repos fetched."
echo -e " ${FMT_GREEN}${no_pulled}${FMT_RESET} repos pulled/rebased."

if [ ${#conflicts[@]} -ne 0 ]
then
  echo -e " ${FMT_RED}${#conflicts[*]}${FMT_RESET} total merge conflicts:"
  for c in ${conflicts[*]}
  do
    echo "   -> ${c}"
  done
fi

echo -e " ${FMT_RED}${#skipped[*]}${FMT_RESET} repos pull/rebase skipped:"
for s in ${skipped[*]}
do
  echo "   -> ${s}"
done

echo -e " ${FMT_RED}${#not_cloned[*]}${FMT_RESET} missing repos:"
for s in ${not_cloned[*]}
do
  echo "   -> ${s}"
done
echo -e "${BLUE}***********************************************************${FMT_RESET}"

exit 0
