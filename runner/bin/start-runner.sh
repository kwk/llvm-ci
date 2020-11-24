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

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${RUNNER_TOKEN}
}

cleanup

# Create the runner and start the configuration experience
./config.sh \
    --url "https://github.com/${GH_OWNER}/${GH_REPO}" \
    --token "${RUNNER_TOKEN}" \
    --replace \
    --unattended

trap 'echo "exiting with 130";  cleanup; exit 130' INT
trap 'echo "exiting with 143"; cleanup; exit 143' TERM
trap 'echo "EXITING with $?";' EXIT

# In case the runner updates we need to restart it
while true; do
    set +e
    ./run.sh
    set -e
done