# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

include ./config.mk

PROJECT_DIR=$(shell pwd)
OUT_DIR=$(PROJECT_DIR)/out

# Create output directory for artifacts and test results
$(shell mkdir -p $(OUT_DIR));

CI_GIT_COMMIT_ID := $(shell git rev-parse --short HEAD)
IS_DIRTY := no
ifneq ($(shell git status --porcelain --untracked-files=no),)
       CI_GIT_COMMIT_ID := $(CI_GIT_COMMIT_ID)-dirty
	   IS_DIRTY := yes
endif

.PHONY: ready-to-deploy
## Will issue an error when the repo is not ready to be deployed
ready-to-deploy:
ifeq ($(IS_DIRTY),yes)
	$(error CAUTION: The repository is dirty, meaning you have uncommitted changes. \
	When you keep changing the same dirty container image and push it to the container image registry, \
	the cluster will not pull it because it thinks it already has it. \
	Commit your changes and then deploy it. This will force the Kubernetes cluster to \
	always grab the fresh copy of your container image.)
endif

ARCH=$(shell arch)

# Find out which container tool to use (currently only podman and docker are supported)
# DOCKER_BIN := $(shell command -v docker 2> /dev/null)
# DOCKER_COMPOSE_BIN := $(shell command -v docker-compose 2> /dev/null)
# PODMAN_BIN := $(shell command -v podman 2> /dev/null)
# PODMAN_COMPOSE_BIN := $(shell command -v podman-compose 2> /dev/null)
# CONTAINER_TOOL := $(shell [[ -z "$(PODMAN_BIN)" ]] && echo $(DOCKER_BIN) || echo $(PODMAN_BIN))
# COMPOSE_TOOL := $(shell [[ -z "$(PODMAN_COMPOSE_BIN)" ]] && echo $(DOCKER_COMPOSE_BIN) || echo $(PODMAN_COMPOSE_BIN))

CONTAINER_TOOL := docker
COMPOSE_TOOL := docker-compose

# This is the default URL:PORT address to the master on your cluster
K8S_NAMESPACE := $(shell kubectl config view --minify --output 'jsonpath={..namespace}')
BUILDBOT_WORKER_PORT := 30007
# TODO(kwk): We don't use this variable yet but except for
# when a "buildbot try" command is executed.
BUILDBOT_TRY_PORT := 30008
BUILDBOT_MASTER := "$(K8S_NAMESPACE)$(K8S_NAMESPACE_URL_PREFIX):$(BUILDBOT_WORKER_PORT)"

.PHONY: show-container-tool
## Show which container tool was automatically selected to be used by make: podman (preferred) or docker.
## QUICK TIP: To overwrite container tool "make CONTAINER_TOOL=/path/to/podman/or/docker <TARGET>"
show-container-tool:
	@echo $(CONTAINER_TOOL)

.PHONY: show-compose-tool
## Show which container tool was automatically selected to be used by make: podman-compose (preferred) or docker-compose.
## QUICK TIP: To overwrite container tool "make COMPOSE_TOOL=/path/to/podman-compose/or/docker-compose <TARGET>"
show-compose-tool:
	@echo $(COMPOSE_TOOL)

.PHONY: show-buildbot-master
## Shows the URL:PORT to that will be used to point workers to the buildbot master
show-buildbot-master:
	@echo $(BUILDBOT_MASTER)

include ./help.mk
include ./worker/worker.mk
include ./master/master.mk
include ./runner/runner.mk

.PHONY: run-locally
## Runs the buildbot master, two workers and a github actions-runner
## on localhost using podman-compose or docker-compose.
run-locally:
	$(COMPOSE_TOOL) build
	$(COMPOSE_TOOL) up