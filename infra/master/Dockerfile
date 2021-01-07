FROM fedora:33

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
    buildbot-master \
    buildbot-www \
    git \
    inotify-tools \
    nano \
    patch \
    python3-service-identity \
    python3-pip \
   && dnf clean all

RUN pip install install txrequests buildbot_prometheus
# ^ txrequests is needed for
#    https://docs.buildbot.net/latest/manual/configuration/reporters/github_comment.html
#    and
#    https://docs.buildbot.net/latest/manual/configuration/reporters/github_status.html#githubstatuspush 


# TODO(kwk): HACK: Manually apply path-modified buildbot patch of PR https://github.com/buildbot/buildbot/pull/5623 
COPY buildbot-pr-5623.patch /
RUN patch -p1 -d / --backup --batch  < /buildbot-pr-5623.patch

RUN mkdir -pv \
    /home/buildbot-master/bin \
    /home/buildbot-master/cfg \
    /home/buildbot-master/basedir

COPY bin/* /home/buildbot-master/bin/
# COPY cfg/* /home/buildbot-master/cfg/
RUN chmod +x /home/buildbot-master/bin/*

# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN chgrp -R 0 /home/buildbot-master \
    && chmod -R g=u /home/buildbot-master /etc/passwd

# Volumes to mount secrets into the container
VOLUME /master-secret-volume

# Volume to mount config file into the container 
# WARNING: Don't forget to mount the whole base dir instead of just the file. 
VOLUME /home/buildbot-master/cfg

USER 10001
WORKDIR /home/buildbot-master

ARG ci_git_revision=master
ENV CI_GIT_REVISION=${ci_git_revision}

# Needed for when you want to run the build locally
ARG ci_container_image_ref
ENV CI_CONTAINER_IMAGE_REF=${ci_container_image_ref}

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"

ENV BUILDBOT_MASTER_PORT=9989
ENV BUILDBOT_WWW_PORT=8010
ENV BUILDBOT_MASTER_TRY_PORT=8031
ENV BUILDBOT_MASTER_TITLE="Default"

ENTRYPOINT [ "/home/buildbot-master/bin/uid_entrypoint.sh" ]

CMD [ "/home/buildbot-master/bin/master.sh" ]
