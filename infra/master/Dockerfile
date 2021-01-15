FROM llvm-ci-base-image

RUN mkdir -pv \
    /home/johndoe/bin \
    /home/johndoe/cfg \
    /home/johndoe/basedir

# See: https://docs.openshift.com/container-platform/3.3/creating_images/guidelines.html#openshift-container-platform-specific-guidelines
RUN chgrp -R 0 /home/johndoe \
    && chmod -R g=u /home/johndoe /etc/passwd

# Volume to mount config file into the container 
# WARNING: Don't forget to mount the whole base dir instead of just the file. 
VOLUME /home/johndoe/cfg

USER 10001

ENV BUILDBOT_MASTER_PORT=9989
ENV BUILDBOT_WWW_PORT=8010
ENV BUILDBOT_MASTER_TRY_PORT=8031
ENV BUILDBOT_MASTER_TITLE="Default"
