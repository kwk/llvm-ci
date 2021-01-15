PREPARE_SECRET_TARGETS += prepare-master-secrets
.PHONY: prepare-master-secrets
## Copies secret templates for the buildbot master and adjusts permissions. 
## NOTE: Existing secrets will be backed up.
prepare-master-secrets:
	@-cp -v --backup=numbered ./master/k8s/secret.yaml.sample ./master/k8s/secret.yaml
	@-cp -v --backup=numbered ./master/compose-secrets/github-pat.sample ./master/compose-secrets/github-pat
	## TODO(kwk): Security concern? Without "others" being able to read the secrets, the master won't start.
	@chmod a+r -v ./master/k8s/secret.yaml
	@chmod a+r -v ./master/compose-secrets/github-pat


###############################################################################
#
# EVERYTHING BELOW IS ONLY RELEVANT WHEN YOU'RE DEALING WITH KUBERNETES.
#
###############################################################################


BUILDBOT_MASTER_IMAGE := $(CONTAINER_IMAGE_REPO):buildbot-master-$(CI_GIT_COMMIT_ID)

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

.PHONY: delete-master-deployment
## Removes all parts of the buildbot master deployment from the cluster
delete-master-deployment:
	-kubectl delete pod,service,route,secret --grace-period=0 --force -l app=buildbot -l tier=master

.PHONY: deploy-master-misc
## Creates the master secret, service, and route on a Kubernetes cluster 
deploy-master-misc: ready-to-deploy
	export SECRET_FILE=$(shell test -f ./master/k8s/secret.yaml && echo ./master/k8s/secret.yaml || echo ./master/k8s/secret.yaml.sample)\
	&& kubectl apply -f $${SECRET_FILE}
	kubectl apply -f ./master/k8s/service.yaml
	kubectl apply -f ./master/k8s/route.yaml

.PHONY: deploy-master
## Deletes and recreates the buildbot master container image as a pod on a Kubernetes cluster.
## Once completed, the master UI will be opened in a browser. Refresh the webpage if
## it doesn't work immediately. It might be that the cluster isn't ready yet.
deploy-master: ready-to-deploy master-image push-master-image delete-master-deployment deploy-master-misc
	export BUILDBOT_MASTER_IMAGE=$(BUILDBOT_MASTER_IMAGE) \
	&& export BUILDBOT_WWW_URL="$(shell kubectl get route master-route-www -o json | jq -j '"http://"+.spec.host+.spec.path')" \
	&& envsubst '$${BUILDBOT_MASTER_IMAGE} $${BUILDBOT_WWW_URL}' < ./master/k8s/pod.yaml > ./out/master-pod.yaml \
	&& kubectl apply -f ./out/master-pod.yaml \
	&& xdg-open $${BUILDBOT_WWW_URL}