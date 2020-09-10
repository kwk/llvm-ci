# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

CI_GIT_COMMIT_ID := $(shell git rev-parse --short HEAD)
ifneq ($(shell git status --porcelain --untracked-files=no),)
       CI_GIT_COMMIT_ID := $(CI_GIT_COMMIT_ID)-dirty
endif

ARCH=$(shell arch)
FEDORA_32_IMAGE_NAME := quay.io/kkleine/llvm-ci:fedora-32-$(ARCH)-$(CI_GIT_COMMIT_ID)
RHEL_8_IMAGE_NAME := quay.io/kkleine/llvm-ci:rhel-8-$(ARCH)-$(CI_GIT_COMMIT_ID)
CENTOS_8_IMAGE_NAME := quay.io/kkleine/llvm-ci:centos-8-$(ARCH)-$(CI_GIT_COMMIT_ID)

.PHONY: fedora-32-image
fedora-32-image: Dockerfile.fedora32
	@echo Building image ${FEDORA_32_IMAGE_NAME}
	podman build \
		--build-arg ci_git_revision=$(CI_GIT_COMMIT_ID) \
		--build-arg ci_container_image_ref=${FEDORA_32_IMAGE_NAME} \
		. \
		-f Dockerfile.fedora32 \
		-t ${FEDORA_32_IMAGE_NAME}

.PHONY: push-fedora-32-image
push-fedora-32-image:
	@echo Pushing image ${FEDORA_32_IMAGE_NAME}
	podman push ${FEDORA_32_IMAGE_NAME}

.PHONY: centos-8-image
centos-8-image: Dockerfile.centos8
	@echo Building image ${CENTOS_8_IMAGE_NAME}
	podman build \
		--build-arg ci_git_revision=$(CI_GIT_COMMIT_ID) \
		--build-arg ci_container_image_ref=${CENTOS_8_IMAGE_NAME} \
		--build-arg arch=$(ARCH) \
		. \
		-f Dockerfile.centos8 \
		-t ${CENTOS_8_IMAGE_NAME}

.PHONY: push-centos-8-image
push-centos-8-image:
	@echo Pushing image ${CENTOS_8_IMAGE_NAME}
	podman push ${CENTOS_8_IMAGE_NAME}

.PHONY: rhel-8-image
rhel-8-image: Dockerfile.rhel8
	@echo Building image ${RHEL_8_IMAGE_NAME}
	podman build \
		--build-arg ci_git_revision=$(CI_GIT_COMMIT_ID) \
		--build-arg ci_container_image_ref=${RHEL_8_IMAGE_NAME} \
		--build-arg arch=$(ARCH) \
		. \
		-f Dockerfile.rhel8 \
		-t ${RHEL_8_IMAGE_NAME}

.PHONY: push-rhel-8-image
push-rhel-8-image:
	@echo Pushing image ${RHEL_8_IMAGE_NAME}
	podman push ${RHEL_8_IMAGE_NAME}

.PHONY: deploy
deploy:
	echo -n "Logged in as "
	oc whoami -c
	oc apply --dry-run=false --overwrite=true -f yaml/pod-config.yaml.sample

