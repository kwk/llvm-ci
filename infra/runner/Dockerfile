FROM  llvm-ci-base-image

RUN mkdir -pv /home/johndoe/actions-runner/ \
    && cd /home/johndoe/actions-runner \
    && curl -O -L https://github.com/actions/johndoe/releases/download/v2.274.1/actions-runner-linux-x64-2.274.1.tar.gz \
    && tar xzf ./actions-runner-linux-x64-2.274.1.tar.gz \
    && rm -v actions-runner-linux-x64-2.274.1.tar.gz \
    && ./bin/installdependencies.sh \
    && dnf clean all

# Changing the permissions of /usr/share/GitHubActionsService is crucial;
# otherwise the auto runner won't be able to write to this directory when it auto-updates.
# TODO(kwk): Can this step be removed?
RUN mkdir -pv /usr/share/GitHubActionsService \
    && chgrp -R 0 /home/johndoe \
    && chmod -R g=u /home/johndoe /etc/passwd /usr/share/GitHubActionsService

#&& chown -RHLv runner:runner /home/johndoe \
    
# TODO(kwk): Use this to get the latest actions-runner:
# && GITHUB_RUNNER_VERSION=$(\
#         curl --silent "https://api.github.com/repos/actions/johndoe/releases/latest" \
#         | jq -r '.tag_name[1:]'\
#     ) \
# && curl -Ls https://github.com/actions/johndoe/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz \
#     | tar xz \


COPY bin/* /home/johndoe/
RUN chmod +x -v /home/johndoe/*.sh
RUN chgrp -R 0 /home/johndoe \
    && chmod -R g=u /home/johndoe /etc/passwd

# Volumes to mount secrets into the container
VOLUME /secret-volume

USER 10001
WORKDIR /home/johndoe

ENV RUNNER_LABELS = "fedora33,container"
ENV RUNNER_NAME = "my-github-actions-runner"

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"

ENTRYPOINT [ "/home/johndoe/uid_entrypoint.sh" ]

CMD [ "/home/johndoe/start-runner.sh" ]



