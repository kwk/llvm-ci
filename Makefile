# When you run make VERBOSE=1, executed commands will be printed before
# executed, verbose flags are turned on and quiet flags are turned off for
# various commands. Use V_FLAG in places where you can toggle on/off verbosity
# using -v. Use Q_FLAG in places where you can toggle on/off quiet mode using
# -q.
Q = @
Q_FLAG = -q
V_FLAG =
ifeq ($(VERBOSE),1)
       Q =
       Q_FLAG = 
       V_FLAG = -v
endif

# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /bin/bash

GIT_COMMIT_ID := $(shell git rev-parse --short HEAD)
ifneq ($(shell git status --porcelain --untracked-files=no),)
       GIT_COMMIT_ID := $(GIT_COMMIT_ID)-dirty
endif

ARCH=$(shell arch)
FEDORA_32_IMAGE_NAME := quay.io/kkleine/llvm-ci:fedora-32-$(ARCH)-$(GIT_COMMIT_ID)
FEDORA_RAWHIDE_IMAGE_NAME := quay.io/kkleine/llvm-ci:fedora-rawhide-$(ARCH)-$(GIT_COMMIT_ID)

.PHONY: fedora-images
fedora-images: fedora-32-image fedora-rawhide-image

.PHONY: fedora-32-image
fedora-32-image: Dockerfile.fedora
	@echo Building image ${FEDORA_32_IMAGE_NAME}
	$(Q)podman build $(Q_FLAG) \
		--build-arg os_version=32 \
		--build-arg git_revision=$(GIT_COMMIT_ID) \
		--build-arg arch=$(ARCH) \
		. \
		-f Dockerfile.fedora \
		-t ${FEDORA_32_IMAGE_NAME}
	@echo Pushing image ${FEDORA_32_IMAGE_NAME}
	$(Q)podman push $(Q_FLAG) ${FEDORA_32_IMAGE_NAME}

.PHONY: fedora-rawhide-image
fedora-rawhide-image: Dockerfile.fedora
	@echo Building image ${FEDORA_RAWHIDE_IMAGE_NAME}
	$(Q)podman build $(Q_FLAG) \
		--build-arg os_version=rawhide \
		--build-arg git_revision=$(GIT_COMMIT_ID) \
		--build-arg arch=$(ARCH) \
		. \
		-f Dockerfile.fedora \
		-t ${FEDORA_RAWHIDE_IMAGE_NAME}
	@echo Pushing ${FEDORA_RAWHIDE_IMAGE_NAME}
	$(Q)podman push $(Q_FLAG) ${FEDORA_RAWHIDE_IMAGE_NAME}
