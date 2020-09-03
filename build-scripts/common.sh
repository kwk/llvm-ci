#!/bin/bash 

set -x
set -e

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

# Output both, stdout and stderr into a log file that we can archive later
exec > >(tee $(basename $0).log) 2>&1