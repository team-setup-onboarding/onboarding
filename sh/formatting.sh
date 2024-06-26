#!/usr/bin/env zsh
set -e -o pipefail

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'
if [ "$(locale charmap)" = UTF-8 ]; then
  CHECKMARK='\0342\0234\0224'
else
  CHECKMARK='[X]'
fi

# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi

# This function uses the logic from supports-hyperlinks[1][2], which is
# made by Kat Marchán (@zkat) and licensed under the Apache License 2.0.
# [1] https://github.com/zkat/supports-hyperlinks
# [2] https://crates.io/crates/supports-hyperlinks
#
# Copyright (c) 2021 Kat Marchán
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
supports_hyperlinks() {
  # $FORCE_HYPERLINK must be set and be non-zero (this acts as a logic bypass)
  if [ -n "$FORCE_HYPERLINK" ]; then
    [ "$FORCE_HYPERLINK" != 0 ]
    return $?
  fi

  # If stdout is not a tty, it doesn't support hyperlinks
  is_tty || return 1

  # DomTerm terminal emulator (domterm.org)
  if [ -n "$DOMTERM" ]; then
    return 0
  fi

  # VTE-based terminals above v0.50 (Gnome Terminal, Guake, ROXTerm, etc)
  if [ -n "$VTE_VERSION" ]; then
    [ $VTE_VERSION -ge 5000 ]
    return $?
  fi

  # If $TERM_PROGRAM is set, these terminals support hyperlinks
  case "$TERM_PROGRAM" in
  Hyper|iTerm.app|terminology|WezTerm) return 0 ;;
  esac

  # kitty supports hyperlinks
  if [ "$TERM" = xterm-kitty ]; then
    return 0
  fi

  # Windows Terminal also supports hyperlinks
  if [ -n "$WT_SESSION" ]; then
    return 0
  fi

  # Konsole supports hyperlinks, but it's an opt-in setting that can't be detected
  # https://github.com/ohmyzsh/ohmyzsh/issues/10964
  # if [ -n "$KONSOLE_VERSION" ]; then
  #   return 0
  # fi

  return 1
}

fmt_link() {
  # $1: text, $2: url, $3: fallback mode
  if supports_hyperlinks; then
    printf '\033]8;;%s\033\\%s\033]8;;\033\\\n' "$2" "$1"
    return
  fi

  case "$3" in
  --text) printf '%s\n' "$1" ;;
  --url|*) fmt_underline "$2" ;;
  esac
}

fmt_underline() {
  is_tty && printf '\033[4m%s\033[24m\n' "$*" || printf '%s\n' "$*"
}

# shellcheck disable=SC2016 # backtick in single-quote
fmt_code() {
  is_tty && printf '`\033[2m%s\033[22m`\n' "$*" || printf '`%s`\n' "$*"
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

setup_color() {
  # Only use colors if connected to a terminal
  if ! is_tty; then
    FMT_RAINBOW=""
    FMT_RED=""
    FMT_GREEN=""
    FMT_YELLOW=""
    FMT_BLUE=""
    FMT_BOLD=""
    FMT_RESET=""
    return
  fi

  FMT_RED=$(tput setaf 1)
  FMT_GREEN=$(tput setaf 2)
  FMT_YELLOW=$(tput setaf 190)
  FMT_BLUE=$(tput setaf 6)
  FMT_BOLD=$(tput bold)
  FMT_RESET=$(tput sgr0)
}


function repeatchar() {
    char=$1
    count=$2
    printf "${char}%.0s" $(seq 1 ${2:?Expected repeat count})
}

function spaces() {
    count=$1
    repeatchar ' ' $count
}

function column() {
    size=$1
    content=$2
    color=$3
    echo -en "  ${color}$content${NC}"
    echo -en "$(spaces $(( $size - ${#content} - 3 )))|"
}

function heading() {
    printf "${FMT_BOLD}$1${FMT_RESET}\n"
    repeatchar '-' ${#1}
}

setup_color

# echo "I search using $(fmt_link google https://google.com)"
# echo "${FMT_RED}Red ${FMT_GREEN}Green ${FMT_BLUE}Blue${FMT_RESET}"
# fmt_underline "Goodbye cruel world..."
# fmt_code "git clone ..."
# fmt_error "It's game over man! Game over..."
# echo -e "Repeat 10x: $(repeatchar 'x' 10)"
# echo -e "0123456789"
# echo -e "$(spaces 10)Should have 10 spaces before the text"
# echo " "
# echo -e "${FMT_RED}Red ${FMT_GREEN}Green ${FMT_BLUE}Blue ${FMT_RESET}No colour"
# echo " "
# echo -e "$(repeatchar '-' 62)"
# echo -en "$(column 14 'Heading 1' $FMT_RESET)"
# echo -en "$(column 14 'Heading 2' $FMT_RESET)"
# echo -e "$(column 34 'Heading 3' $FMT_RESET)"
# echo -e "$(repeatchar '-' 62)"
# echo -en "$(column 14 'Hello' $FMT_BLUE)"
# echo -en "$(column 14 'World' $FMT_GREEN)"
# echo -e "$(column 34 'Note the newline at the end' $FMT_RESET)"
# echo -en "$(column 14 'Goodbye' $FMT_BLUE)"
# echo -en "$(column 14 'Universe' $FMT_GREEN)"
# echo -e "$(column 34 'Also has a newline at the end' $FMT_RESET)"
# echo -e "${FMT_RED}$(repeatchar '-' 62)${FMT_RESET}"
# echo -e "$(heading 'big heading')"
# echo ""

