FROM fedora:33

ENV LANG=en_US.utf8

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
    buildbot-worker \
    curl \
    git \
    tar \
   && yum clean all

# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN useradd --create-home runner \
    && mkdir -pv /home/runner/bin \
    && chgrp -R 0 /home/runner \
    && chmod -R g=u /home/runner /etc/passwd

COPY bin/* /home/runner/bin
ENV PATH="/home/runner/bin:${PATH}" HOME=/home/runner
RUN chmod +x /home/runner/bin/*

# Volumes to mount secrets into the container
VOLUME /runner-secret-volume

USER 10001
WORKDIR /home/runner

# Download and install Github's self-hosted runner client
RUN mkdir actions-runner \
    && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v2.274.1/actions-runner-linux-x64-2.274.1.tar.gz \
    && tar xzf ./actions-runner-linux-x64-2.274.1.tar.gz \
    && rm -v actions-runner-linux-x64-2.274.1.tar.gz

ARG ci_git_revision=master
ENV CI_GIT_REVISION=${ci_git_revision}

# Needed for when you want to run the build locally
ARG ci_container_image_ref
ENV CI_CONTAINER_IMAGE_REF=${ci_container_image_ref}

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"

ENTRYPOINT [ "uid_entrypoint.sh" ]

CMD [ "start-runner.sh" ]



