#! /usr/bin/env bash
set -e

BLUE='\033[0;34m'

echo -e "${BLUE}-----------------------------------------"
echo -e "${BLUE}Cloning all mandatory repositories..."

#PROTO="${1:-http}"
GHREPOS=($(team github repos -ssh))

for ghrepo in "${GHREPOS[@]}"
do
    # invoke repo clone on each of the mandatory repos
    os repos clone ${ghrepo}
    # echo ${ghrepo}
done

echo -e "${BLUE}-----------------------------------------"
echo -e "${BLUE}Done."

exit 0
