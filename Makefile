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

.PHONY: fedora-images
fedora-images: fedora-32-image fedora-rawhide-image

.PHONY: fedora-32-image
fedora-32-image: Dockerfile.fedora
	$(Q)podman build --build-arg osversion=32 ${Q_FLAG} \
		. \
		-f Dockefile.fedora \
		-t quay.io/kkleine/llvm-ci/fedora:32-$(shell arch)-${GIT_COMMIT_ID}
	$Q(podman) push quay.io/kkleine/llvm-ci/fedora:32-$(shell arch)-${GIT_COMMIT_ID}

.PHONY: fedora-rawhide-image
fedora-rawhide-image: Dockerfile.fedora
	$(Q)podman build --build-arg osversion=rawhide ${Q_FLAG} \
		. \
		-f Dockefile.fedora \
		-t quay.io/kkleine/llvm-ci/fedora:rawhide-$(shell arch)-${GIT_COMMIT_ID}
	$Q(podman) push quay.io/kkleine/llvm-ci/fedora:rawhide-$(shell arch)-${GIT_COMMIT_ID}
