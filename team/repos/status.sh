#!/usr/bin/env zsh

set -eo pipefail

source $TEAM_HOME/onboarding/sh/formatting.sh

declare -a REPOS=()


function print_status() {
  # ${1##*/}: for the variable $1, and the pattern '/', the two hashes mean from the 
  # beginning of the parameter, delete the longest (or greedy) match—up to 
  # and including the pattern.
  # ${1%/*} : for the variable $1 and the pattern '/', the percent means from the end
  # of the parameter, the shortest or non-greedy match is deleted
    echo -en "$(column 60 ${1##${TEAM_HOME}/})"
    cd ${1}
    latestCommit=$(git log -1 --pretty="%h" 2> /dev/null) || printf ""
    echo -n "$(column 15 $latestCommit)"
    changed_files=$(git status -s | wc -l)
    unpushed_changes=$(git log --branches --not --remotes --oneline | wc -l)
    commit_count=$(git rev-list --all --count)
    echo -n "$(column 12 $commit_count)"
    if (( ${changed_files} > 0 ))
    then
      echo -ne "$(column 10 'Dirty' $FMT_RED)"
    else
      echo -ne "$(column 10 'Clean' $FMT_GREEN)"
    fi
    if (( ${unpushed_changes} > 0 ))
    then
      echo -ne "$(column 12 'Unpushed' $FMT_RED)"
    else
      echo -ne "$(column 12 'Pushed' $FMT_GREEN)"
    fi
}

function add_status() {
  echo -e "$(print_status $1)"
}

echo -en "$(column 60 'Repository' $FMT_BLUE)"
echo -en "$(column 15 'Last Commit' $FMT_BLUE)"
echo -en "$(column 12 'Commits' $FMT_BLUE)"
echo -en "$(column 10 'Status' $FMT_BLUE)"
echo -e "$(column 12 'Status' $FMT_BLUE)"
echo -e "$(repeatchar '-' 109)"

while IFS=  read -r line
do
  REPOS+=("$line")
done < <(find ${TEAM_HOME} -type d -name ".git" ! -path ${TEAM_HOME} | sed 's!/.git$!!' | grep -v '/\.terraform/')

cd ${TEAM_HOME}

for repo in ${REPOS[*]}
do
  echo -e "$(print_status $repo)"
#  add_status $repo &
done
wait

exit 0
