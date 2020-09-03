#!/bin/bash 

source $(dirname "$0")/common.sh

export PATH="${PATH}:${PWD}/bin"

echo "--- Clang Tidy"
git diff -U0 --no-prefix HEAD~1 | clang-tidy-diff -p0