FROM fedora:33

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
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

# NOTE: When this is started with docker-compose,
#       replace /buildbot-worker-secret-volume with /run/secrets.
ENV BUILDBOT_WORKER_NAME_PATH="/buildbot-worker-secret-volume/buildbot-worker-name"
ENV BUILDBOT_WORKER_PASSWORD_PATH="/buildbot-worker-secret-volume/buildbot-worker-password"
################################################################################

COPY bin/* /home/worker/bin/
ENV PATH="/home/worker/bin:${PATH}" HOME=/home/worker
RUN chmod +x /home/worker/bin/*

# Volumes to mount secrets into the container
VOLUME /buildbot-worker-secret-volume

USER 10001
WORKDIR /home/worker

ARG ci_git_revision=master
ENV CI_GIT_REVISION=${ci_git_revision}

# Needed for when you want to run the build locally
ARG ci_container_image_ref
ENV CI_CONTAINER_IMAGE_REF=${ci_container_image_ref}

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"

ENTRYPOINT [ "uid_entrypoint.sh" ]

CMD [ "start-worker.sh" ]



