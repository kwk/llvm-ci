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

# For the global "prepare-secrets" target all targets in this variable will be executed
PREPARE_SECRET_TARGETS =

PROJECT_DIR=$(shell pwd)

ARCH=$(shell arch)

CONTAINER_TOOL := docker
COMPOSE_TOOL := docker-compose

BUILDBOT_WORKER_PORT := 30007
# TODO(kwk): We don't use this variable yet but except for
# when a "buildbot try" command is executed.
BUILDBOT_TRY_PORT := 30008
BUILDBOT_MASTER := ":$(BUILDBOT_WORKER_PORT)"

.PHONY: show-buildbot-master
## Shows the URL:PORT to that will be used to point workers to the buildbot master
show-buildbot-master:
	@echo $(BUILDBOT_MASTER)

include ./help.mk

PREPARE_SECRET_TARGETS += prepare-worker-secrets
.PHONY: prepare-worker-secrets
## Copies secret templates for the worker (NOTE: existing secrets will be backed up).
prepare-worker-secrets:
	-cp -v --backup=numbered ./worker/compose-secrets/buildbot-worker-name.sample ./worker/compose-secrets/buildbot-worker-name
	-cp -v --backup=numbered ./worker/compose-secrets/buildbot-worker-password.sample ./worker/compose-secrets/buildbot-worker-password

WORKER_IMAGE := buildbot-worker
.PHONY: worker-image
## Generates a container image to be used as a worker for buildbot.
worker-image: worker/Dockerfile
	@echo Building image ${WORKER_IMAGE}
	cd worker \
	&& $(CONTAINER_TOOL) build \
		. \
		-f Dockerfile \
		-t ${WORKER_IMAGE}


PREPARE_SECRET_TARGETS += prepare-master-secrets
.PHONY: prepare-master-secrets
## Copies secret templates for the buildbot master and adjusts permissions. 
## NOTE: Existing secrets will be backed up.
prepare-master-secrets:
	@-cp -v --backup=numbered ./master/compose-secrets/github-pat.sample ./master/compose-secrets/github-pat
	## TODO(kwk): Security concern? Without "others" being able to read the secrets, the master won't start.
	@chmod a+r -v ./master/compose-secrets/github-pat

BUILDBOT_MASTER_IMAGE := buildbot-master

.PHONY: master-image
## Generates a container image that functions as a buildbot master.
master-image: master/Dockerfile
	@echo Building image ${BUILDBOT_MASTER_IMAGE}
	cd master \
	&& $(CONTAINER_TOOL) build \
		. \
		-f Dockerfile \
		-t ${BUILDBOT_MASTER_IMAGE}

include ./runner/runner.mk

# Take the git "origin" remote's user part to determine a github user repository
GIT_ORIGIN_USER := $(shell git ls-remote --get-url origin | cut -d ':' -f 2 | cut -d '/' -f 1)
GIT_ORIGIN_REPO := $(shell git ls-remote --get-url origin | cut -d ':' -f 2 | cut -d '/' -f 2 | sed -s 's/\.git$$//g')

.PHONY: buildbot-try-secrets-in-github
## Create three github secrets (TRY_USER, TRY_PASSWORD and ACTIONS_RUNNER_DEBUG) in your fork.
## Will be used by the actions runner to federate access to the buildbot master.
## For the debug secret see: https://docs.github.com/en/free-pro-team@latest/actions/managing-workflow-runs/enabling-debug-logging
# TODO(kwk): Add BOT_PAT secret here so that messages from buildbot or the github workflow can use the same GH user.
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
	$(CONTAINER_TOOL) build $(Q_FLAG) ./base-image/ -t llvm-ci-base-image -f base-image/Dockerfile
	$(COMPOSE_TOOL) build $(Q_FLAG)
	$(COMPOSE_TOOL) up --remove-orphans -d
	@echo -n "Waiting until Buildbot master Web-UI is up."
	@timeout 22 sh -c 'until curl $(S_FLAG) --insecure -Sf https://localhost:8443/#/workers > /dev/null 2>&1; do echo -n "."; sleep 0.1; done'
	@echo "DONE"
	@echo "Opening Buildbot Workers Web UI (https://localhost:8443/#/workers)"
	@xdg-open https://localhost:8443/#/workers
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

