# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

# Create output directory for artifacts and test results
$(shell mkdir -p ./out);

CI_GIT_COMMIT_ID := $(shell git rev-parse --short HEAD)
ifneq ($(shell git status --porcelain --untracked-files=no),)
       CI_GIT_COMMIT_ID := $(CI_GIT_COMMIT_ID)-dirty
endif

ARCH=$(shell arch)
FEDORA_32_IMAGE_NAME := quay.io/kkleine/llvm-ci:fedora-32-$(ARCH)-$(CI_GIT_COMMIT_ID)

# Find out which container tool to use (currently only podman and docker are supported)
DOCKER_BIN := $(shell command -v docker 2> /dev/null)
PODMAN_BIN := $(shell command -v podman 2> /dev/null)
CONTAINER_TOOL := $(shell [[ -z "$(PODMAN_BIN)" ]] && echo $(DOCKER_BIN) || echo $(PODMAN_BIN))

.PHONY: fedora-32-image
fedora-32-image: Dockerfile.fedora32
	@echo Building image ${FEDORA_32_IMAGE_NAME}
	$(CONTAINER_TOOL) build \
		--build-arg ci_git_revision=$(CI_GIT_COMMIT_ID) \
		--build-arg ci_container_image_ref=${FEDORA_32_IMAGE_NAME} \
		. \
		-f Dockerfile.fedora32 \
		-t ${FEDORA_32_IMAGE_NAME}

.PHONY: push-fedora-32-image
push-fedora-32-image:
	@echo Pushing image ${FEDORA_32_IMAGE_NAME}
	$(CONTAINER_TOOL) push ${FEDORA_32_IMAGE_NAME}

.PHONY: deploy-secrets
deploy-secrets:
	-kubectl delete secret --force=true --grace-period=0 buildkite-secret
	-kubectl delete secret --force=true --grace-period=0 buildbot-secret
	kubectl apply --dry-run=false --overwrite=true -f ./kubernetes/buildkite-secret.yaml
	kubectl apply --dry-run=false --overwrite=true -f ./kubernetes/buildbot-secret.yaml

.PHONY: deploy
deploy: deploy-secrets
	-kubectl delete pod --force=true --grace-period=0 llvm-ci-fedora-32-x8664-pod
	sed 's|PLACE_IMAGE_HERE|${FEDORA_32_IMAGE_NAME}|g' kubernetes/pod-config.yaml.sample > ./out/pod-config.yaml
	kubectl apply --dry-run=false --overwrite=true -f ./out/pod-config.yaml


