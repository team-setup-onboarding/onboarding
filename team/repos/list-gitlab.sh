#!/usr/bin/env zsh

set -eo pipefail

source $RTL_HOME/hello-world/sh/formatting.sh

GROUP_NAME="myTeamName"
KEY="-ssh"
if [[ $# -gt 0 ]]; then
    KEY="$1"
fi

list_repos_in_group() {
  group_full_path=$1
  case $KEY in
      -short)
      curl "https://gitlab.com/api/graphql" --header "Authorization: Bearer $(rtl g _g)" 2>/dev/null \
       --header "Content-Type: application/json" --request POST \
       --data "{\"query\": \"query {group(fullPath: \\\"${group_full_path}\\\") {projects {nodes {name archived}}}}\"}" | jq '.data.group.projects.nodes[] | select(.archived == false) | .name' \
       | sed -e 's/^"//' -e 's/"$//' -e "s!^!${group_full_path}/!" -e "s!^${GROUP_NAME}/!!"
      ;;

      -ssh)
      curl "https://gitlab.com/api/graphql" --header "Authorization: Bearer $(rtl g _g)" 2>/dev/null \
       --header "Content-Type: application/json" --request POST \
       --data "{\"query\": \"query {group(fullPath: \\\"${group_full_path}\\\") {projects {nodes {sshUrlToRepo archived}}}}\"}" | jq '.data.group.projects.nodes[] | select(.archived == false) | .sshUrlToRepo' \
       | sed -e 's/^"//' -e 's/"$//'
      ;;

#      -json)
#      curl "https://gitlab.com/api/graphql" --header "Authorization: Bearer $(rtl g _g)" 2>/dev/null \
#       --header "Content-Type: application/json" --request POST \
#       --data "{\"query\": \"query {group(fullPath: \\\"${group_full_path}\\\") { projects { edges { node { name sshUrlToRepo archived description dora { metrics {  changeFailureRate  date  deploymentFrequency  leadTimeForChanges  timeToRestoreService  value} } pipelines { count } }  }  }  } } \"}" \
#       | jq '.data.group.projects.edges[].node | select(.archived == false)'
#      ;;
#
#      -json-deleted)
#      curl "https://gitlab.com/api/graphql" --header "Authorization: Bearer $(rtl g _g)" 2>/dev/null \
#       --header "Content-Type: application/json" --request POST \
#       --data "{\"query\": \"query {group(fullPath: \\\"${group_full_path}\\\") { projects { edges { node { name sshUrlToRepo archived description dora { metrics {  changeFailureRate  date  deploymentFrequency  leadTimeForChanges  timeToRestoreService  value} } pipelines { count } }  }  }  } } \"}" \
#       | jq '.data.group.projects.edges[].node | select(.archived == true)'
#      ;;

      *)
          echo
          echo "<option> is one of:"
          echo "   -short         : list of all repo names"
          echo "   -ssh           : all the ssh urls for cloning"
#          echo "   -json          : raw json list of repos"
#          echo "   -json-deleted  : raw json list of archived repos"
      ;;

  esac
}

list_all_gitlab_repos_recursively(){
  group="myTeamName"
  >&2 echo "${FMT_GREEN}looking for gitlab repos... ${FMT_RESET}"

#  >&2 echo "${FMT_BLUE}getting repos from group '${group}'${FMT_RESET}"
  list_repos_in_group $group

  while IFS= read line
  do
#    >&2 echo "${FMT_BLUE}getting repos from group '$line'${FMT_RESET}"
    list_repos_in_group $line
  done < <(curl "https://gitlab.com/api/graphql" --header "Authorization: Bearer $(rtl g _g)" 2>/dev/null \
                --header "Content-Type: application/json" --request POST \
                --data "{\"query\": \"query {group(fullPath: \\\"${group}\\\") {descendantGroups{ nodes { fullPath } } }}\"}" | jq -r '.data.group.descendantGroups.nodes[].fullPath')
  >&2 echo "${FMT_GREEN}gitlab repos found${FMT_RESET} ${FMT_GREEN}${CHECKMARK}${FMT_RESET}"
}

list_all_gitlab_repos_recursively

