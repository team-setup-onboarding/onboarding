#! /usr/bin/env zsh
set -e

source $TEAM_HOME/onboarding/sh/formatting.sh
cd $TEAM_HOME
EXISTS=()
NEW=()

log_repo_status() {
  repository=$1

  if [[ -d $repository ]]
  then
    EXISTS+=("$repository")
    echo -en "$(column ${col_repo_width} $repository $BLUE)"
    echo -e "$(column ${col_status_width} "exists" $GREEN)"
  else
    echo -en "$(column ${col_repo_width} $repository $BLUE)"
    echo -e "$(column ${col_status_width} 'installing...' $RED)"
    NEW+=("$repository")
  fi
}

echo -e "${BLUE}."
echo -e "${BLUE}Cloning all mandatory repositories..."

#PROTO="${1:-http}"
GHREPOS=($(team r l))

col_repo_width=90
col_status_width=20
table_width=$(($col_repo_width + $col_status_width))

echo -en "$(column ${col_repo_width} "repository" $NC)"
echo -e "$(column ${col_status_width} "status" $NC)"
echo -e "$(repeatchar '-' ${table_width})"

for ghrepo in "${GHREPOS[@]}"
do
    log_repo_status $ghrepo $directory
done

for installrepo in "${NEW[@]}"
do
  git clone git@github.com:team-setup-onboarding/${installrepo}.git
done

echo -e "${BLUE}-----------------------------------------"
echo -e "${BLUE}Done."

exit 0
