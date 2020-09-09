#!/bin/bash 

# This is the secret you should set from outside
export BUILDKITE_AGENT_TOKEN=${BUILDKITE_AGENT_TOKEN:-"<REPLACE_ME>"}

# Adapt this to whatever docker base image this builds on and what settings you have configured LLVM with
export BUILDKITE_AGENT_TAGS=${BUILDKITE_AGENT_TAGS:-"os=fedora,os_version=32,arch=${arch},ci_git_revision=${ci_git_revision}"}

# Ensure we only download the latest version and not more
export BUILDKITE_GIT_CLONE_FLAGS=${BUILDKITE_GIT_CLONE_FLAGS:-"-v --depth=1"}

# Don't automatically run ssh-keyscan before checkout
export BUILDKITE_NO_SSH_KEYSCAN=${BUILDKITE_NO_SSH_KEYSCAN:-1}

# Don't show colors in logging
export BUILDKITE_AGENT_NO_COLOR=${BUILDKITE_AGENT_NO_COLOR:-1}

# Start an HTTP server on this addr:port that returns whether the agent is healthy, disabled by default
export BUILDKITE_AGENT_HEALTH_CHECK_ADDR=${BUILDKITE_AGENT_HEALTH_CHECK_ADDR:-"0.0.0.0:9090"}

/usr/bin/buildkite-agent start