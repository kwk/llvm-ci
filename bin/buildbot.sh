#!/bin/bash

set -eu

# Ensure Bash pipelines (e.g. cmd | othercmd) return a non-zero status if any of
# the commands fail, rather than returning the exit status of the last command
# in the pipeline.
set -o pipefail

# Read the worker name and password from a mounted file.
BUILDBOT_WORKER_NAME=$(cat /buildbot-secret-volume/buildbot-worker-name)
BUILDBOT_WORKER_PASSWORD=$(cat /buildbot-secret-volume/buildbot-worker-password)

BUILDBOT_WORKER_BASE_DIR="${BUILDBOT_BASEDIR}/${BUILDBOT_WORKER_NAME}"
BUILDBOT_WORKER_INFO_DIR="${BUILDBOT_WORKER_BASE_DIR}/info"

mkdir -p ${BUILDBOT_WORKER_INFO_DIR}

echo ${BUILDBOT_INFO_ADMIN} > "${BUILDBOT_WORKER_INFO_DIR}/admin"

worker-info.sh | tee ${BUILDBOT_WORKER_INFO_DIR}/host

BUILDBOT_ACCESS_URI=${BUILDBOT_ACCESS_URI:-""}
[[ "${BUILDBOT_ACCESS_URI}" != "" ]] && (echo ${BUILDBOT_ACCESS_URI} | tee ${BUILDBOT_WORKER_INFO_DIR}/access_uri)

BUILDBOT_MASTER=${BUILDBOT_MASTER:-"lab.llvm.org:9994"}
BUILDBOT_CREATE_WORKER_OPTS=${BUILDBOT_CREATE_WORKER_OPTS:-}

buildslave create-slave \
    ${BUILDBOT_CREATE_WORKER_OPTS} \
    "${BUILDBOT_WORKER_BASE_DIR}" \
    "${BUILDBOT_MASTER}"  \
    "${BUILDBOT_WORKER_NAME}" \
    "${BUILDBOT_WORKER_PASSWORD}"

# TODO(kwk): Don't know if that could be useful
# ulimit -S -n 2048

# TODO(kwk): Once migrated to buildbot 2, this could be used instead
# buildbot-worker create-worker \
#     ${BUILDBOT_CREATE_WORKER_OPTS} \
#     "${BUILDBOT_WORKER_BASE_DIR}" \
#     "${BUILDBOT_MASTER}" \
#     "${BUILDBOT_WORKER_NAME}" \
#     "${BUILDBOT_WORKER_PASSWORD}"

# This command returns immediately
buildslave start "${BUILDBOT_WORKER_BASE_DIR}" || (tail ${BUILDBOT_WORKER_BASE_DIR}/twistd.log && exit 1)

echo "Following worker log..."
tail -f ${BUILDBOT_WORKER_BASE_DIR}/twistd.log