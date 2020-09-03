#!/bin/bash 

source $(dirname "$0")/common.sh

export PATH="${PATH}:${PWD}/bin"

echo "--- Clang Format"
../clang/tools/clang-format/git-clang-format HEAD~1
