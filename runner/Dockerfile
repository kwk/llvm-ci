FROM fedora:33

ENV LANG=en_US.utf8

# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN useradd --create-home runner

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
        buildbot-worker \
        curl \
        git \
        tar \
    && mkdir -pv /home/runner/actions-runner \
    && cd /home/runner/actions-runner \
    && export ACTIONS_RUNNER_VERSION=2.274.1 \
    && curl -O -L https://github.com/actions/runner/releases/download/v${ACTIONS-RUNNER_VERSION}/actions-runner-linux-x64-${ACTIONS-RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${ACTIONS-RUNNER_VERSION}.tar.gz \
    && rm -v actions-runner-linux-x64-${ACTIONS-RUNNER_VERSION}.tar.gz \
    && ./bin/installdependencies.sh \
    && chgrp -R 0 /home/runner \
    && chmod -R g=u /home/runner /etc/passwd \
    && yum clean all

COPY bin/* /home/runner/bin
ENV PATH="/home/runner/bin:${PATH}" HOME=/home/runner
RUN chmod +x /home/runner/bin/*

# Volumes to mount secrets into the container
VOLUME /runner-secret-volume

USER 10001
WORKDIR /home/runner

ARG ci_git_revision=master
ENV CI_GIT_REVISION=${ci_git_revision}

# Needed for when you want to run the build locally
ARG ci_container_image_ref
ENV CI_CONTAINER_IMAGE_REF=${ci_container_image_ref}

ENV RUNNER_LABELS = "fedora33,container"
ENV RUNNER_NAME = "my-github-actions-runner"

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"

ENTRYPOINT [ "uid_entrypoint.sh" ]

CMD [ "start-runner.sh" ]



