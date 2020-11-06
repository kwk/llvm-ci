FROM fedora:33

ENV LANG=en_US.utf8

RUN echo -e "\
[buildkite-agent] \n\
name            = Buildkite Pty Ltd \n\
baseurl         = https://yum.buildkite.com/buildkite-agent/stable/$(arch)/ \n\
enabled         = 1 \n\
priority        = 1 \n\
gpgcheck        = 0\
" > /etc/yum.repos.d/buildkite-agent.repo

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
    buildkite-agent \
    buildbot-worker \
    ccache \
    clang \
    cmake \
    diffutils \
    findutils \
    gcc \
    gdb \
    git \
    glibc-all-langpacks \
    golang \
    lld \
    libatomic \
    libedit-devel \
    libstdc++-static \
    libxml2-devel \
    make \
    nano \
    ncurses-devel \
    ninja-build \
    python3-psutil \
    python3 \
    python3-devel \
    redhat-lsb-core \
    rsync \
    swig \
    xz-devel \
    zip \
   && yum clean all

# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN useradd --create-home worker \
    && mkdir -pv /home/worker/bin \
    && chgrp -R 0 /home/worker \
    && chmod -R g=u /home/worker /etc/passwd

################################################################################
#
#       BUILDKITE SPECIFICS
#
################################################################################

# WORKAROUND FOR OPENSHIFT BECAUSE "USER" COMMAND WILL BE IGNORED
# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN chgrp -R 0 /etc/buildkite-agent /var/lib/buildkite-agent && \
    chmod -R g=u /etc/buildkite-agent /var/lib/buildkite-agent

# ATTENTION: "USER" WILL BE IGNORED BY OPENSHIFT (see above)
# USER buildkite-agent

ENV BUILDKITE_BUILD_PATH=/home/worker/buildkite/builds
RUN mkdir -p ${BUILDKITE_BUILD_PATH}

# This allows you to split the build cache and the builds itself into different
# volumes.
RUN mkdir -p ${BUILDKITE_BUILD_PATH} /ccache \
    && chgrp -R 0 ${BUILDKITE_BUILD_PATH} /ccache \
    && chmod -R g=u ${BUILDKITE_BUILD_PATH} /ccache /etc/passwd
VOLUME ["${BUILDKITE_BUILD_PATH}", "/ccache"]

ENV BUILDKITE_AGENT_TAGS=""

# Ensure we only download the latest version and not more
ENV BUILDKITE_GIT_CLONE_FLAGS="-v --depth=1"

# Don't automatically run ssh-keyscan before checkout
ENV BUILDKITE_NO_SSH_KEYSCAN=1

# Don't show colors in logging
ENV BUILDKITE_AGENT_NO_COLOR=1

# Start an HTTP server on this addr:port that returns whether the agent is healthy, disabled by default
ENV BUILDKITE_AGENT_HEALTH_CHECK_ADDR="0.0.0.0:9090"

################################################################################
#
#       BUILDBOT SPECIFICS
#
################################################################################

# Port choices
# 9994 = staging
# 9990 = production
ENV BUILDBOT_MASTER="lab.llvm.org:9994"

# All commands are run in a build-specific subdirectory of this base dir
ENV BUILDBOT_BASEDIR="/home/worker/buildbot"

# Options passed to buildbot-worker create-worker
ENV BUILDBOT_CREATE_WORKER_OPTS=""

# Will be visible from the build status page. So you may wish to munge it a bit
# if address-harvesting spambots are a concern.
ENV BUILDBOT_INFO_ADMIN="Your Name <yourname at email dot com>"

ENV BUILDBOT_ACCESS_URI=""

################################################################################

COPY bin/* /home/worker/bin
ENV PATH="/home/worker/bin:${PATH}" HOME=/home/worker
RUN chmod +x /home/worker/bin/*

# Volumes to mount secrets into the container
VOLUME /buildbot-worker-secret-volume
VOLUME /buildkite-secret-volume

# 9090 is supposed to be our health port for buildkite
EXPOSE \
  9090/tcp

# We check the health of the container by checking the
# https://docs.docker.com/engine/reference/builder/#healthcheck)
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:9090/ || exit 1

RUN yum install -y iputils traceroute net-tools nmap && yum clean all


USER 10001
WORKDIR /home/worker

ARG ci_git_revision=master
ENV CI_GIT_REVISION=${ci_git_revision}

# Needed for when you want to run the build locally
ARG ci_container_image_ref
ENV CI_CONTAINER_IMAGE_REF=${ci_container_image_ref}

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"
# Build-time metadata as defined at http://label-schema.org
ARG build_date
LABEL org.label-schema.build-date=$build_date \
      org.label-schema.name="LLVM CI" \
      org.label-schema.description="A container for running LLVM CI bots (e.g. buildbot or buildkite) jobs" \
      org.label-schema.url="https://github.com/kwk/llvm-ci" \
      org.label-schema.vcs-ref=$ci_container_image_ref \
      org.label-schema.vcs-url="https://github.com/kwk/llvm-ci" \
      org.label-schema.version=$ci_container_image_ref \
      org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run -it --rm --env YOURBUILDBOTCONFIG -v -v BUILDBOTSECRET:/buildbot-secret-volume $ci_container_image_ref buildbot.sh" \
      org.label-schema.docker.debug="docker exec -it $CONTAINER bash" \
      org.label-schema.docker.params="BUILDBOT_MASTER=URL to buildbot master (e.g. lab.llvm.org:9994)"

ENTRYPOINT [ "uid_entrypoint.sh" ]

CMD [ "buildbot-worker.sh" ]



