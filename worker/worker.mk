WORKER_IMAGE := $(CONTAINER_IMAGE_REPO):worker-fedora-33-$(ARCH)-$(CI_GIT_COMMIT_ID)

.PHONY: worker-image
## Generates a container image to be used as a worker for buildbot.
worker-image: worker/Dockerfile
	@echo Building image ${WORKER_IMAGE}
	cd worker \
	&& $(CONTAINER_TOOL) build \
		--build-arg ci_git_revision=$(CI_GIT_COMMIT_ID) \
		--build-arg ci_container_image_ref=${WORKER_IMAGE} \
		--build-arg build_date="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		. \
		-f Dockerfile \
		-t ${WORKER_IMAGE}

.PHONY: push-worker-image
## Pushes the worker container images to a registry.
push-worker-image:
	@echo Pushing image ${WORKER_IMAGE}
	$(CONTAINER_TOOL) push ${WORKER_IMAGE}

.PHONY: delete-worker-deployment
## Removes all parts of the buildbot worker deployment from the cluster
delete-worker-deployment:
	-kubectl delete pod,secret --grace-period=0 --force -l app=buildbot -l tier=worker

.PHONY: deploy-worker
## Deletes and recreates the worker container image as a pod on a Kubernetes cluster.
deploy-worker: ready-to-deploy worker-image push-worker-image delete-worker-deployment
	export SECRET_FILE=$(shell test -f ./worker/k8s/secret.yaml && echo ./worker/k8s/secret.yaml || echo ./worker/k8s/secret.yaml.sample)\
	&& kubectl apply -f $${SECRET_FILE}
	export WORKER_IMAGE=$(WORKER_IMAGE) \
	&& export BUILDBOT_MASTER="$(BUILDBOT_MASTER)" \
	&& envsubst '$${WORKER_IMAGE} $${BUILDBOT_MASTER}' < ./worker/k8s/pod.yaml > ./out/worker-pod.yaml
	kubectl apply -f ./out/worker-pod.yaml