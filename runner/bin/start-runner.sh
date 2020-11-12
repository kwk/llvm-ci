#!/bin/bash

set -eu

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

# Read the worker name and password from a mounted file.
RUNNER_TOKEN=$(cat /runner-secret-volume/runner-token)
RUNNER_URL=$(cat /runner-secret-volume/runner-url)

# Create the runner and start the configuration experience
actions-runner/config.sh --url ${RUNNER_URL} --token ${RUNNER_TOKEN}

# Last step, run it!
actions-runner/run.sh