FROM llvm-ci-base-image

# Port choices
# 9994 = staging
# 9990 = production
ENV BUILDBOT_MASTER="lab.llvm.org:9994"

# All commands are run in a build-specific subdirectory of this base dir
ENV BUILDBOT_BASEDIR="/home/johndoe/buildbot"

# Options passed to buildbot-worker create-worker
ENV BUILDBOT_CREATE_WORKER_OPTS=""

# Will be visible from the build status page. So you may wish to munge it a bit
# if address-harvesting spambots are a concern.
ENV BUILDBOT_INFO_ADMIN="Your Name <yourname at email dot com>"

ENV BUILDBOT_ACCESS_URI=""
################################################################################

ENV PATH="/home/johndoe/bin:${PATH}" HOME=/home/johndoe
RUN chmod +x /home/johndoe/bin/*

USER 10001



