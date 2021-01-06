PREPARE_SECRET_TARGETS += prepare-runner-secrets
.PHONY: prepare-runner-secrets
## Copies secret templates for the runner (NOTE: existing secrets will be backed up).
prepare-runner-secrets:
	-cp -v --backup=numbered ./runner/k8s/secret.yaml.sample ./runner/k8s/secret.yaml
	-cp -v --backup=numbered ./runner/compose-secrets/github-pat.sample ./runner/compose-secrets/github-pat


###############################################################################
#
# EVERYTHING BELOW IS ONLY RELEVANT WHEN YOU'RE DEALING WITH KUBERNETES.
#
###############################################################################


RUNNER_IMAGE := $(CONTAINER_IMAGE_REPO):runner-fedora-33-$(ARCH)-$(CI_GIT_COMMIT_ID)

.PHONY: runner-image
## Generates a container image to be used as a github self-hosted runner.
runner-image: runner/Dockerfile
	@echo Building image ${RUNNER_IMAGE}
	cd runner \
	&& $(CONTAINER_TOOL) build \
		--build-arg ci_git_revision=$(CI_GIT_COMMIT_ID) \
		--build-arg ci_container_image_ref=${RUNNER_IMAGE} \
		--build-arg build_date="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		. \
		-f Dockerfile \
		-t ${RUNNER_IMAGE}

.PHONY: push-runner-image
## Pushes the runner container images to a registry.
push-runner-image:
	@echo Pushing image ${RUNNER_IMAGE}
	$(CONTAINER_TOOL) push ${RUNNER_IMAGE}

.PHONY: delete-runner-deployment
## Removes all parts of the buildbot runner deployment from the cluster
delete-runner-deployment:
	-kubectl delete pod,secret --grace-period=0 --force -l app=buildbot -l tier=runner

.PHONY: deploy-runner
## Deletes and recreates the runner container image as a pod on a Kubernetes cluster.
deploy-runner: ready-to-deploy runner-image push-runner-image delete-runner-deployment
	export SECRET_FILE=$(shell test -f ./runner/k8s/secret.yaml && echo ./runner/k8s/secret.yaml || echo ./runner/k8s/secret.yaml.sample)\
	&& kubectl apply -f $${SECRET_FILE}
	export RUNNER_IMAGE=$(RUNNER_IMAGE) \
	&& envsubst '$${RUNNER_IMAGE}' < ./runner/k8s/pod.yaml > ./out/runner-pod.yaml
	kubectl apply -f ./out/runner-pod.yaml