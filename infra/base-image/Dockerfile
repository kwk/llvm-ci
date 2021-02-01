FROM fedora:33

# For the github actions runner we need these packages: https://github.com/actions/runner/blob/main/docs/start/envlinux.md#full-dependencies-list
# lttng-ust openssl-libs krb5-libs zlib libicu

# For .NET on Fedora see: https://docs.microsoft.com/en-us/dotnet/core/install/linux-fedora
# dotnet-sdk-5.0 aspnetcore-runtime-5.0 dotnet-runtime-5.0 dotnet-sdk-3.1 aspnetcore-runtime-3.1 dotnet-runtime-3.1 compat-openssl10

ADD https://packages.microsoft.com/config/fedora/33/prod.repo /etc/yum.repos.d/microsoft-prod.repo
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
    aspnetcore-runtime-3.1 \
    aspnetcore-runtime-5.0 \
    ccache \
    clang \
    cmake \
    compat-openssl10 \
    curl \
    diffutils \
    dotnet-runtime-3.1 \
    dotnet-runtime-5.0 \
    dotnet-sdk-3.1 \
    dotnet-sdk-5.0 \
    findutils \
    gcc \
    gdb \
    git \
    glibc-all-langpacks \
    golang \
    inotify-tools \
    jq \
    krb5-libs \
    libatomic \
    libedit-devel \
    libicu \
    libstdc++-static \
    libxml2-devel \
    lld \
    lttng-ust \
    make \
    nano \
    ncurses-devel \
    ninja-build \
    openssl-libs \
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
    zlib \
   && dnf clean all

# Install Buildbot from pip
# See http://trac.buildbot.net/wiki/RunningBuildbotWithVirtualEnv
RUN useradd --create-home johndoe
WORKDIR /home/johndoe
USER johndoe
COPY requirements.txt requirements.txt
RUN virtualenv sandbox \
    && source sandbox/bin/activate \
    && python -m pip install --upgrade pip \
    && source sandbox/bin/activate \
    && pip install --requirement requirements.txt
USER root

# Volumes to mount secrets into the container
VOLUME /secret-volume

COPY home/ /home/johndoe/

ARG ci_git_revision=main
ENV CI_GIT_REVISION=${ci_git_revision}

# Needed for when you want to run the build locally
ARG ci_container_image_ref
ENV CI_CONTAINER_IMAGE_REF=${ci_container_image_ref}

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"

ENTRYPOINT [ "/home/johndoe/bin/uid_entrypoint.sh" ]

CMD [ "/home/johndoe/bin/start.sh" ]

ONBUILD COPY home/ /home/johndoe/
ONBUILD RUN ls /home/johndoe
ONBUILD RUN chmod +x /home/johndoe/bin/*
ONBUILD RUN chgrp -R 0 /home/johndoe \
        && chmod -R g=u /home/johndoe /etc/passwd
