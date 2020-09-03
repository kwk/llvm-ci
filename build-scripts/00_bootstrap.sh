#!/bin/bash 

source $(dirname "$0")/common.sh

echo "--- Bootstrap"

# Generate list of installed packages
yum list installed > installed_packages.txt

echo "--- Clear CCache (make it cold)"
ccache --clear

echo "--- Clean CCache Stats"
ccache --zero-stats