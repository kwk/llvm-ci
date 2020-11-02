BUILDBOT_MASTER_IMAGE := quay.io/kkleine/lvm-ci:buildbot-master-fedora-33-$(ARCH)-$(CI_GIT_COMMIT_ID)

.PHONY: master-image
## Generates a container image that functions as a buildbot master.
master-image: master/Dockerfile
	@echo Building image ${BUILDBOT_MASTER_IMAGE}
	cd master \
	&& $(CONTAINER_TOOL) build \
		--build-arg ci_git_revision=$(CI_GIT_COMMIT_ID) \
		--build-arg ci_container_image_ref=${BUILDBOT_MASTER_IMAGE} \
		--build-arg build_date="$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")" \
		. \
		-f Dockerfile \
		-t ${BUILDBOT_MASTER_IMAGE}

.PHONY: push-master-image
## Pushes the buildbot master container image to a registry.
push-master-image:
	@echo Pushing image ${BUILDBOT_MASTER_IMAGE}
	$(CONTAINER_TOOL) push ${BUILDBOT_MASTER_IMAGE}

.PHONY: run-local-master
## Runs the master container image locally for quick testing.
## QUICK TIP: To start a bash and not the actual buildbot master run "make run-local-master bash"
run-local-master: master-image
	@echo "Go to http://localhost:8010 to visit the buildbot"
	$(CONTAINER_TOOL) run -it --rm \
		--env BUILDBOT_MASTER_PORT=9989 \
		-p 9989:9989 \
		--env BUILDBOT_WWW_PORT=8010 \
		-p 8010:8010 \
		--env BUILDBOT_WWW_URL="http://localhost:8010/" \
		--env BUILDBOT_MASTER_TITLE="My LOCAL Buildbot CI" \
		${BUILDBOT_MASTER_IMAGE} $(filter-out $@,$(MAKECMDGOALS))

.PHONY: delete-master-deployment
## Removes all parts of the buildbot master deployment from the cluster
delete-master-deployment:
	-kubectl delete pod,service,route,secret -l app=buildbot-master

.PHONY: deploy-master
## Deletes and recreates the buildbot master container image as a pod on a Kubernetes cluster.
## Once completed, the master UI will be opened in a browser. Refresh the webpage if
## it doesn't work immediately. It might be that the cluster isn't ready yet.
deploy-master: delete-master-deployment
 	kubectl apply --dry-run=false --overwrite=true -f ./master/k8s/secret.yaml
	kubectl apply --dry-run=false --overwrite=true -f ./master/k8s/service.yaml
	kubectl apply --dry-run=false --overwrite=true -f ./master/k8s/route.yaml
	export BUILDBOT_MASTER_IMAGE=$(BUILDBOT_MASTER_IMAGE) \
	&& export BUILDBOT_WWW_URL="$(shell kubectl get route master-route -o json | jq -j '"http://"+.spec.host+.spec.path')" \
	&& envsubst '$${BUILDBOT_MASTER_IMAGE} $${BUILDBOT_WWW_URL}' < ./master/k8s/pod.yaml > ./out/master-pod.yaml \
	&& kubectl apply --dry-run=false --overwrite=true -f ./out/master-pod.yaml \
	&& xdg-open $${BUILDBOT_WWW_URL}