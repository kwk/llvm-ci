# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

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
## Will issue a warning when the repo is not ready to be deployed
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
DOCKER_BIN := $(shell command -v docker 2> /dev/null)
PODMAN_BIN := $(shell command -v podman 2> /dev/null)
CONTAINER_TOOL := $(shell [[ -z "$(PODMAN_BIN)" ]] && echo $(DOCKER_BIN) || echo $(PODMAN_BIN))

.PHONY: show-container-tool
## Show which container tool was automatically selected to be used by make: podman (preferred) or docker.
## QUICK TIP: To overwrite container tool "make CONTAINER_TOOL=/path/to/podman/or/docker <TARGET>"
show-container-tool:
	@echo $(CONTAINER_TOOL)

include ./help.mk
include ./worker/worker.mk
include ./master/master.mk