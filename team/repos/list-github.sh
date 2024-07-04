#!/usr/bin/env bash
set -Eeu -o pipefail

key=""
if [[ $# -gt 0 ]]; then
    key="$1"
else
    key="-short"
fi

team github repos $key
