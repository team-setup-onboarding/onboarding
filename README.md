# Onboarding
A collection of tools and scripts to create a team onboarding repo, 
which includes a team CLI to assist with discovery about tooling, 
scripts and repos available to the GitHub team.

## Getting started
1. Clone this repo
2. Execute the script `sh/onboarding.sh`
3. Explore the CLI by typing `team` on the command line

## Prerequisites
* You're using a modern mac
* Use zsh with [Robby Russell's oh-my-zsh](https://ohmyz.sh/) installed
* [HomeBrew](https://brew.sh/) is installed

## Using the team cli
See what commands are available to you
```shell
team
```
### repos
You can explore the repos belonging to the team.  First login to github
```shell
team gh login
```
View all the repos belonging to this team
```shell
team repos list -ssh
```
Checkout all the repos belonging to this team
```shell
team repos clone-all
```
git pull rebase all your repos
```shell
team repos update-all
```
### setup pairs for commits
There is a mechanism for automatically adding pair programmers to git commit
messages. GitLab honours this and lists the pair along side the actual committer.

Show the pair commands
```shell
team pair
```
List all the pairs
```shell
team pair pairs-list
```