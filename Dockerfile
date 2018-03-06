# install files extract
FROM busybox:latest AS install_files

RUN mkdir -p /install/oe117/

# the install file has to be in the same directory as this Dockerfile
#COPY PROGRESS_OE_11.7_LNX_64_EVAL.tar.gz /install/oe117/

# pull the install file from local file server like HFS
RUN wget http://192.168.0.10/workspaces/docker-oe117-db/PROGRESS_OE_11.7_LNX_64_EVAL.tar.gz -P /install/oe117/
RUN tar -xf /install/oe117/PROGRESS_OE_11.7_LNX_64_EVAL.tar.gz --directory /install/oe117/
RUN rm /install/oe117/PROGRESS_OE_11.7_LNX_64_EVAL.tar.gz

###############################################

# db install using install files
FROM centos:7.3.1611 AS as_install

# get the install files
COPY --from=install_files /install/oe117/ /install/oe117/
# copy our response.ini in from our test install
COPY response.ini /install/oe117/

#do a background progress install with our response.ini
RUN /install/oe117/proinst -b /install/oe117/response.ini -l silentinstall.log

###############################################

# actual db server image
FROM centos:7.3.1611

LABEL maintainer="Nick Heap (nickheap@gmail.com)" \
 version="0.1" \
 description="Appserver Image for OpenEdge 11.7.1" \
 oeversion="11.7.1"

# copy openedge files in
COPY --from=as_install /usr/dlc/ /usr/dlc/

# Add Tini
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# add startup script
WORKDIR /usr/wrk
COPY start.sh .
COPY as_ping.p .
COPY as_activate.p .

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
# OPENEDGE_DB="openedge" \
# OPENEDGE_HOST="0.0.0.0" \
# OPENEDGE_BROKER_PORT="20666" \
# OPENEDGE_ALIAS="oe"

# the directory and volume for the database data
RUN mkdir -p /var/lib/openedge/data/
VOLUME /var/lib/openedge/data/

EXPOSE $APPSERVER_PORT $ADMINSERVER_PORT $APPSERVER_MINPORT-$APPSERVER_MINPORT

# Run start.sh under Tini
CMD ["/usr/wrk/start.sh"]
