WORKER_IMAGE := quay.io/kkleine/llvm-ci:fedora-33-$(ARCH)-$(CI_GIT_COMMIT_ID)

.PHONY: worker-image
## Generates a container image to be used as a worker for buildbot or buildkite.
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

.PHONY: run-local-worker
## Runs the worker container image locally for quick testing.
run-local-worker: worker-image
	$(CONTAINER_TOOL) run -it --rm ${WORKER_IMAGE} bash 

.PHONY: delete-worker-deployment
## Removes all parts of the buildbot worker deployment from the cluster
delete-worker-deployment:
	-kubectl delete pod,secret -l app=worker

.PHONY: deploy-worker
## Deletes and recreates the worker container image as a pod on a Kubernetes cluster.
deploy-worker: delete-worker-deployment
	kubectl apply -f ./worker/k8s/buildbot-secret.yaml
	kubectl apply -f ./worker/k8s/buildkite-secret.yaml
	envsubst '$${WORKER_IMAGE}' < ./worker/k8s/pod.yaml > ./out/worker-pod.yaml
	kubectl apply -f ./out/worker-pod.yaml