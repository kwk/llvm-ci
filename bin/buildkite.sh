#!/bin/bash 

set -eu

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

BUILDKITE_AGENT_TOKEN=$(cat /buildkite-secret-volume/buildkite-agent-token)

/usr/bin/buildkite-agent start --token ${BUILDKITE_AGENT_TOKEN}