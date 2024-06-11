#!/usr/bin/env zsh

set -eo pipefail

source $TEAM_HOME/onboarding/sh/formatting.sh

local -a EXISTS=()
local -a NEW=()

cd $TEAM_HOME

echo ""
echo -e "$(heading 'Fetching repos from gitlab...')"
echo ""

repos=($(team r l))

col_repo_width=90
col_status_width=20
table_width=$(($col_repo_width + $col_status_width))

echo -en "$(column ${col_repo_width} "repository" $NC)"
echo -e "$(column ${col_status_width} "status" $NC)"
echo -e "$(repeatchar '-' ${table_width})"

log_repo_status() {
  repository=$1
  directory=$2

  if [[ -d $directory ]]
  then
    EXISTS+=("$repository")
    echo -en "$(column ${col_repo_width} $repository $BLUE)"
    echo -e "$(column ${col_status_width} "exists" $GREEN)"
  else
    echo -en "$(column ${col_repo_width} $repository $BLUE)"
    echo -e "$(column ${col_status_width} 'installing...' $NC)"
    NEW+=("$repository")
  fi
}

for repository in ${repos[@]}
do
  log_repo_status $repository $directory
  [[ -d $directory ]] || git clone $repository $directory
done

echo "Done"
