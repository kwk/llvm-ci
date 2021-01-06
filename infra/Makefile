# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

include ./config.mk

PROJECT_DIR=$(shell pwd)

# For the global "prepare-secrets" target all targets in this variable will be executed
PREPARE_SECRET_TARGETS =s

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
## Show which container tool was automatically selected to be used by make: docker (preferred) podman.
## QUICK TIP: To overwrite container tool "make CONTAINER_TOOL=/path/to/docker/or/podman <TARGET>"
show-container-tool:
	@echo $(CONTAINER_TOOL)

.PHONY: show-compose-tool
## Show which container tool was automatically selected to be used by make: docker-compose (preferred) or podman-compose.
## QUICK TIP: To overwrite container tool "make COMPOSE_TOOL=/path/to/docker-compose/or/podman-compose <TARGET>"
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
## on localhost using docker-compose or podman-compose.
run-locally:
	$(COMPOSE_TOOL) build --quiet
	$(COMPOSE_TOOL) up --remove-orphans -d
	@echo -n "Waiting until Buildbot master Web-UI is up."
	@timeout 22 sh -c 'until curl -sSf http://localhost:8010/#/workers > /dev/null 2>&1; do echo -n "."; sleep 0.1; done'
	@echo "DONE"
	@echo "Opening Buildbot Workers Web UI (http://localhost:8010/#/workers)"
	@xdg-open http://localhost:8010/#/workers

# Take the git "origin" remote's user part to determine a github user repository
GIT_ORIGIN_USER := $(shell git ls-remote --get-url origin | cut -d ':' -f 2 | cut -d '/' -f 1)
GIT_ORIGIN_REPO := $(shell git ls-remote --get-url origin | cut -d ':' -f 2 | cut -d '/' -f 2 | sed -s 's/\.git$$//g')

# Keep this "prepare-secrets" target here at the bottom
.PHONY: prepare-secrets
## Runs all prepare-XY-secret targets.
prepare-secrets: $(PREPARE_SECRET_TARGETS)
	$(info Prepare docker environment file:)
	echo "GH_OWNER=$(GIT_ORIGIN_USER)" > .env
	echo "GH_REPO=$(GIT_ORIGIN_REPO)" >> .env

