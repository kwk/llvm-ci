FROM fedora:33

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
    ccache \
    clang \
    cmake \
    curl \
    diffutils \
    findutils \
    gcc \
    gdb \
    git \
    glibc-all-langpacks \
    golang \
    inotify-tools \
    jq \
    libatomic \
    libedit-devel \
    libstdc++-static \
    libxml2-devel \
    lld \
    make \
    nano \
    ncurses-devel \
    ninja-build \
    patch \
    python3 \
    python3-devel \
    python3-pip \
    python3-psutil \
    python3-service-identity \
    python3-virtualenv \
    redhat-lsb-core \
    rsync \
    swig \
    tar \
    xz-devel \
    zip \
   && dnf clean all

# Install Buildbot from pip
# See http://trac.buildbot.net/wiki/RunningBuildbotWithVirtualEnv
RUN useradd --create-home johndoe
WORKDIR /home/johndoe
USER johndoe
RUN virtualenv sandbox \
    && source sandbox/bin/activate \
    && python -m pip install --upgrade pip \
    && source sandbox/bin/activate \
    && pip install buildbot[bundle]

COPY bin/* /home/johndoe/bin/
# COPY cfg/* /home/johndoe/cfg/
RUN chmod +x /home/johndoe/bin/*

USER root

# Volumes to mount secrets into the container
VOLUME /secret-volume

COPY bin/uid_entrypoint.sh /home/johndoe/bin/uid_entrypoint.sh
RUN chmod +x /home/johndoe/bin/uid_entrypoint.sh

ARG ci_git_revision=main
ENV CI_GIT_REVISION=${ci_git_revision}

# Needed for when you want to run the build locally
ARG ci_container_image_ref
ENV CI_CONTAINER_IMAGE_REF=${ci_container_image_ref}

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"

ENTRYPOINT [ "/home/johndoe/bin/uid_entrypoint.sh" ]

CMD [ "/home/johndoe/bin/start.sh" ]

ONBUILD COPY home/* /home/johndoe
ONBUILD RUN chmod +x /home/johndoe/bin/*
ONBUILD RUN chgrp -R 0 /home/johndoe \
        && chmod -R g=u /home/johndoe /etc/passwd