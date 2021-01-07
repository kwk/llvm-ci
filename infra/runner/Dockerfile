FROM fedora:33

# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN useradd --create-home runner

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
        buildbot \
        curl \
        git \
        jq \
        patch \
        strace \
        tar \
    && mkdir -pv /home/runner/actions-runner/ \
    && cd /home/runner/actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v2.274.1/actions-runner-linux-x64-2.274.1.tar.gz \
    && tar xzf ./actions-runner-linux-x64-2.274.1.tar.gz \
    && rm -v actions-runner-linux-x64-2.274.1.tar.gz \
    && ./bin/installdependencies.sh \
    && dnf clean all

# TODO(kwk): HACK: Manually apply path-modified buildbot patch of PR https://github.com/buildbot/buildbot/pull/5623 
COPY buildbot-pr-5623.patch /
RUN patch -p1 -d / --backup --batch  < /buildbot-pr-5623.patch

# Changing the permissions of /usr/share/GitHubActionsService is crucial;
# otherwise the auto runner won't be able to write to this directory when it auto-updates.
RUN mkdir -pv /usr/share/GitHubActionsService \
    && chgrp -R 0 /home/runner \
    && chmod -R g=u /home/runner /etc/passwd /usr/share/GitHubActionsService

#&& chown -RHLv runner:runner /home/runner \
    
# TODO(kwk): Use this to get the latest actions-runner:
# && GITHUB_RUNNER_VERSION=$(\
#         curl --silent "https://api.github.com/repos/actions/runner/releases/latest" \
#         | jq -r '.tag_name[1:]'\
#     ) \
# && curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz \
#     | tar xz \


COPY bin/* /home/runner/
RUN chmod +x -v /home/runner/*.sh
RUN chgrp -R 0 /home/runner \
    && chmod -R g=u /home/runner /etc/passwd
    

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

ENTRYPOINT [ "/home/runner/uid_entrypoint.sh" ]

CMD [ "/home/runner/start-runner.sh" ]



