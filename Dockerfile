# as install using install files
FROM oe117-setup:latest AS as_install

# copy our response.ini in from our test install
COPY conf/response.ini /install/oe117/

#do a background progress install with our response.ini
RUN /install/oe117/proinst -b /install/oe117/response.ini -l silentinstall.log

###############################################

# actual db server image
FROM centos:7.3.1611

LABEL maintainer="Nick Heap (nickheap@gmail.com)" \
 version="0.1" \
 description="Appserver Image for OpenEdge 11.7.1" \
 oeversion="11.7.1"

# Add Tini
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# copy openedge files in
COPY --from=as_install /usr/dlc/ /usr/dlc/

# the directories for the appserver code
RUN mkdir -p /var/lib/openedge/base/ && mkdir -p /var/lib/openedge/code/
COPY src/as_ping.p /var/lib/openedge/base/
COPY src/as_activate.p /var/lib/openedge/base/

COPY conf/ubroker.properties /var/lib/openedge/properties/

# add startup script
WORKDIR /usr/wrk

COPY scripts/start.sh .

# set required vars
ENV \
 TERM="xterm" \
 JAVA_HOME="/usr/dlc/jdk/bin" \
 PATH="$PATH:/usr/dlc/bin:/usr/dlc/jdk/bin" \
 DLC="/usr/dlc" \
 WRKDIR="/usr/wrk" \
 PROCFG="" \
 APPSERVER_PORT="21000" \
 APPSERVER_MINPORT="21100" \
 APPSERVER_MAXPORT="21200" \
 ADMINSERVER_PORT="3090"

# volume for application code
VOLUME /var/lib/openedge/code/

EXPOSE $APPSERVER_PORT $ADMINSERVER_PORT $APPSERVER_MINPORT-$APPSERVER_MINPORT

# Run start.sh under Tini
CMD ["/usr/wrk/start.sh"]

