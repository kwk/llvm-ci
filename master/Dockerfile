FROM fedora:33

ENV LANG=en_US.utf8

RUN dnf install -y --setopt=tsflags=nodocs --setopt=install_weak_deps=False \
    buildbot-master \
    buildbot-www \
    git \
    nano \
    patch \
    python3-service-identity \
   && yum clean all

# TODO(kwk): HACK: Manually apply path-modified buildbot patch of PR buildbot/buildbot#5623 
COPY buildbot-pr-5623.patch /
RUN patch -p1 -d / --backup --batch  < /buildbot-pr-5623.patch

# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
# RUN useradd --create-home buildbot-master \
RUN mkdir -pv /home/buildbot-master/bin /home/buildbot-master/basedir \
    && chgrp -R 0 /home/buildbot-master \
    && chmod -R g=u /home/buildbot-master /etc/passwd

COPY bin/* /home/buildbot-master/bin
COPY master.cfg /home/buildbot-master/basedir/master.cfg
ENV PATH="/home/buildbot-master/bin:${PATH}" HOME=/home/buildbot-master
RUN chmod +x /home/buildbot-master/bin/*

# Volumes to mount secrets into the container
VOLUME /master-secret-volume

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
ENV BUILDBOT_MASTER_TITLE="Buildbot on PSI"

ENTRYPOINT [ "uid_entrypoint.sh" ]

CMD [ "master.sh" ]



