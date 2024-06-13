#!/usr/bin/env bash
set -Eeu -o pipefail

key=""
if [[ $# -gt 1 ]]; then
    key="$2"
else
    key="-short"
fi

team github repos $key

