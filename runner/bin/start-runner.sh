#!/bin/bash

set -eu

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

GH_PAT=$(cat /runner-secret-volume/github-pat)

# Request a new actions-runner token
# (See https://developer.github.com/v3/actions/self-hosted-runners/#create-a-registration-token-for-a-repository)
RUNNER_TOKEN=$(curl -s -XPOST -H "Authorization: token ${GH_PAT}" https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token | jq .token --raw-output)

cd actions-runner

config() {
    # Create the runner and start the configuration experience
    ./config.sh \
        --url "https://github.com/${GH_OWNER}/${GH_REPO}" \
        --token "${RUNNER_TOKEN}" \
        --replace \
        --unattended
}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${RUNNER_TOKEN}
}

config

trap 'cleanup;' EXIT

./bin/runsvc.sh

cleanup