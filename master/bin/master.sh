#!/bin/bash

set -eu

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

BUILDBOT_MASTER_BASEDIR=/home/buildbot-master/basedir

buildbot create-master "${BUILDBOT_MASTER_BASEDIR}"

buildbot start "${BUILDBOT_MASTER_BASEDIR}" || (tail ${BUILDBOT_MASTER_BASEDIR}/twistd.log && exit 1)

echo "Following master log..."
tail -f ${BUILDBOT_MASTER_BASEDIR}/twistd.log