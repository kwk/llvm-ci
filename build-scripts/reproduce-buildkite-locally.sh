#!/bin/bash 

set -e

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

echo "--- Reproduce build locally"
echo "Start a container:"
echo "podman run -it --rm --entrypoint bash ${CONTAINER_IMAGE_REF}"
echo "Inside the container run:"
echo "su buildkite-agent"
echo "cd /var/lib/buildkite-agent/builds"
echo "mkdir -p mybuild"
echo "cd mybuild"
echo "git clone ${BUILDKITE_REPO} llvm-project"
echo "cd llvm-project"
echo "git checkout ${BUILDKITE_COMMIT}"
echo "/build-scripts/build.sh"