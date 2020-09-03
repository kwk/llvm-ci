#!/bin/bash 

source $(dirname "$0")/common.sh

export PATH="${PATH}:${PWD}/bin"

echo "--- Show CCache statistics" 
ccache --show-stats
