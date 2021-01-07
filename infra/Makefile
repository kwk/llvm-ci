# When you run make VERBOSE=1, executed commands will be printed before
# executed, verbose flags are turned on and quiet flags are turned off for
# various commands. Use V_FLAG in places where you can toggle on/off verbosity
# using -v. Use Q_FLAG in places where you can toggle on/off quiet mode using
# -q.
Q = @
Q_FLAG = -q
V_FLAG =
S_FLAG = -s
ifeq ($(VERBOSE),1)
       Q =
       S_FLAG = 
       Q_FLAG = 
       V_FLAG = -v
endif

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

# Take the git "origin" remote's user part to determine a github user repository
GIT_ORIGIN_USER := $(shell git ls-remote --get-url origin | cut -d ':' -f 2 | cut -d '/' -f 1)
GIT_ORIGIN_REPO := $(shell git ls-remote --get-url origin | cut -d ':' -f 2 | cut -d '/' -f 2 | sed -s 's/\.git$$//g')

.PHONY: buildbot-try-secrets-in-github
## Create three github secrets (TRY_USER, TRY_PASSWORD and ACTIONS_RUNNER_DEBUG) in your fork.
## Will be used by the actions runner to federate access to the buildbot master.
## For the debug secret see: https://docs.github.com/en/free-pro-team@latest/actions/managing-workflow-runs/enabling-debug-logging
buildbot-try-secrets-in-github:
	gh secret set TRY_USER -balice-try -R $(GIT_ORIGIN_USER)/$(GIT_ORIGIN_REPO)
	gh secret set TRY_PASSWORD -bpassword -R $(GIT_ORIGIN_USER)/$(GIT_ORIGIN_REPO)
	gh secret set ACTIONS_RUNNER_DEBUG -btrue -R $(GIT_ORIGIN_USER)/$(GIT_ORIGIN_REPO)

.PHONY: start
## Runs the buildbot infrastructure and a github actions-runner
## on localhost using docker-compose or podman-compose.
## Upon launch, buildbot website is opened in your default browser
## and the compose tool's logs are followed.
start:
	$(COMPOSE_TOOL) build $(Q_FLAG)
	$(COMPOSE_TOOL) up --remove-orphans -d
	@echo -n "Waiting until Buildbot master Web-UI is up."
	@timeout 22 sh -c 'until curl $(S_FLAG) -Sf http://localhost:8010/#/workers > /dev/null 2>&1; do echo -n "."; sleep 0.1; done'
	@echo "DONE"
	@echo "Opening Buildbot Workers Web UI (http://localhost:8010/#/workers)"
	@xdg-open http://localhost:8010/#/workers
	@echo "Following compose logs"
	$(COMPOSE_TOOL) logs -f

.PHONY: stop
stop:
	$(COMPOSE_TOOL) stop -t0
	$(COMPOSE_TOOL) rm -f

# Keep this "prepare-secrets" target here at the bottom
.PHONY: prepare-secrets
## Runs all prepare-XY-secret targets and prepare the docker environment file ".env".
prepare-secrets: $(PREPARE_SECRET_TARGETS)
	$(info Prepare docker environment file:)
	echo "GH_OWNER=$(GIT_ORIGIN_USER)" > .env
	echo "GH_REPO=$(GIT_ORIGIN_REPO)" >> .env

