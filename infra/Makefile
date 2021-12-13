# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash
# For the global "prepare-secrets" target all targets in this variable will be executed
PREPARE_SECRET_TARGETS =
PROJECT_DIR=$(shell pwd)
ARCH=$(shell arch)

include ./help.mk

.PHONY: start
## Runs the buildbot infrastructure and a github actions-runner
## on localhost using docker-compose or podman-compose.
## Upon launch, buildbot website is opened in your default browser
## and the compose tool's logs are followed.
start:
	docker-compose build
	docker-compose up --remove-orphans -d
	@echo -n "Waiting until Buildbot master Web-UI is up."
	@timeout 22 sh -c 'until curl --insecure -Sf https://localhost:8443/#/workers > /dev/null 2>&1; do echo -n "."; sleep 0.1; done'
	@echo "DONE"
	@echo "Opening Buildbot Workers Web UI (https://localhost:8443/#/workers)"
	@xdg-open https://localhost:8443/#/workers
	@echo "Following compose logs"
	docker-compose logs -f

.PHONY: stop
stop:
	docker-compose stop -t0
	docker-compose rm -f

# ---------------- buildbot worker ----------------

PREPARE_SECRET_TARGETS += prepare-bb-worker-secrets
.PHONY: prepare-bb-worker-secrets
## Copies secret templates for the worker (NOTE: existing secrets will be backed up).
prepare-bb-worker-secrets:
	-cp -v --backup=numbered ./bb-worker/compose-secrets/buildbot-worker-name.sample ./bb-worker/compose-secrets/buildbot-worker-name
	-cp -v --backup=numbered ./bb-worker/compose-secrets/buildbot-worker-password.sample ./bb-worker/compose-secrets/buildbot-worker-password

# BB_WORKER_IMAGE := bb-worker
# .PHONY: bb-worker-image
# ## Generates a container image to be used as a worker for buildbot.
# bb-worker-image: bb-worker/Dockerfile
# 	@echo Building image ${BB_WORKER_IMAGE}
# 	cd worker && docker build .-f Dockerfile -t ${BB_WORKER_IMAGE}

# ---------------- buildbot master ----------------

PREPARE_SECRET_TARGETS += prepare-bb-master-secrets
.PHONY: prepare-bb-master-secrets
## Copies secret templates for the buildbot master and adjusts permissions. 
## NOTE: Existing secrets will be backed up.
prepare-bb-master-secrets:
	@-cp -v --backup=numbered ./bb-master/compose-secrets/github-pat.sample ./bb-master/compose-secrets/github-pat
	## TODO(kwk): Security concern? Without "others" being able to read the secrets, the master won't start.
	@chmod a+r -v ./bb-master/compose-secrets/github-pat

# BB_MASTER_IMAGE := bb-master

# .PHONY: bb-master-image
# ## Generates a container image that functions as a buildbot master.
# bb-master-image: bb-master/Dockerfile
# 	@echo Building image ${BB_MASTER_IMAGE}
# 	cd master && docker build . -f Dockerfile -t ${BB_MASTER_IMAGE}

# ---------------- github runner ----------------

PREPARE_SECRET_TARGETS += prepare-github-runner-secrets
.PHONY: prepare-github-runner-secrets
## Copies secret templates for the runner (NOTE: existing secrets will be backed up).
prepare-github-runner-secrets:
	-cp -v --backup=numbered ./github-runner/compose-secrets/github-pat.sample ./github-runner/compose-secrets/github-pat

# GITHUB_RUNNER_IMAGE := github-runner-image

# .PHONY: github-runner-image
# ## Generates a container image to be used as a github self-hosted runner.
# github-runner-image: github-runner/Dockerfile
# 	@echo Building image ${GITHUB_RUNNER_IMAGE}
# 	cd runner && docker build . -f Dockerfile -t ${GITHUB_RUNNER_IMAGE}

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

# Keep this "prepare-secrets" target here at the bottom
.PHONY: prepare-secrets
## Runs all prepare-XY-secret targets and prepare the docker environment file ".env".
## The .env file is for dynamically setting environment variables in the docker containers.
prepare-secrets: $(PREPARE_SECRET_TARGETS)
	$(info Prepare docker environment file:)
	echo "GH_OWNER=$(GIT_ORIGIN_USER)" > .env
	echo "GH_REPO=$(GIT_ORIGIN_REPO)" >> .env

