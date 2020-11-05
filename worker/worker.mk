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
## QUICK TIP: To start a bash and not the actual worker run "make run-local-worker bash"
run-local-worker: worker-image
	export SECRET_DIR=$(shell mktemp -d -p $(OUT_DIR)) \
	&& chmod a+rwx $${SECRET_DIR} \
	&& echo "example-worker" > $${SECRET_DIR}/buildbot-worker-name \
	&& echo 'password' > $${SECRET_DIR}/buildbot-worker-password \
	&& $(CONTAINER_TOOL) run -it --rm \
	-v $${SECRET_DIR}:/buildbot-worker-secret-volume:Z \
	--env BUILDBOT_MASTER="master-route-workers-llvm-pre-merge.apps.ocp.prod.psi.redhat.com:80" \
	${WORKER_IMAGE} bash

.PHONY: delete-worker-deployment
## Removes all parts of the buildbot worker deployment from the cluster
delete-worker-deployment:
	-kubectl delete pod,secret --grace-period=0 --force -l app=worker

.PHONY: deploy-worker
## Deletes and recreates the worker container image as a pod on a Kubernetes cluster.
deploy-worker: ready-to-deploy worker-image push-worker-image delete-worker-deployment
	kubectl apply -f ./worker/k8s/buildbot-secret.yaml
	kubectl apply -f ./worker/k8s/buildkite-secret.yaml
	export WORKER_IMAGE=$(WORKER_IMAGE) \
	&& export BUILDBOT_MASTER="$(shell kubectl get route master-route-workers -o json | jq -j '"http://"+.spec.host+.spec.path')" \
	&& export BUILDBOT_ACCESS_URI="https://console-openshift-console.apps.ocp.prod.psi.redhat.com/k8s/ns/llvm-pre-merge/pods/worker-pod" \
	&& envsubst '$${WORKER_IMAGE} $${BUILDBOT_MASTER} $${BUILDBOT_ACCESS_URI}' < ./worker/k8s/pod.yaml > ./out/worker-pod.yaml
	kubectl apply -f ./out/worker-pod.yaml