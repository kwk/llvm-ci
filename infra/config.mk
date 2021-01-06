
# Change this to your own container image repo (e.g. on quay.io or docker hub)
# NOTE: Tags will be appended to this repo URL using a ":"
CONTAINER_IMAGE_REPO := quay.io/kkleine/llvm-ci

# This is the address that is being used to construct the NodePort URI for the buildbot
# workers as in: <Namespace>.<K8S_NAMESPACE_URL_PREFIX>:<NodePort>
# TODO(kwk): Can we automagically determine this?
K8S_NAMESPACE_URL_PREFIX := .apps.ocp.prod.psi.redhat.com

