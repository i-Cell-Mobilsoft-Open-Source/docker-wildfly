ARG BASE_IMAGE
ARG ARTIFACT_DOWNLOADER_IMAGE

################################################################################
# Download IBM MQ driver
################################################################################
FROM $ARTIFACT_DOWNLOADER_IMAGE as download

ARG POM_GROUP_ID
ARG POM_ARTIFACT_ID
ARG POM_VERSION
ARG POM_EXTENSION

ENV NEXUS_OBJECT_GROUP_ID=$POM_GROUP_ID
ENV NEXUS_OBJECT_ARTIFACT_ID=$POM_ARTIFACT_ID
ENV NEXUS_OBJECT_VERSION=$POM_VERSION
ENV NEXUS_OBJECT_EXTENSION=$POM_EXTENSION

ENV NEXUS_DOWNLOAD_OUTPUT_FILE_NAME=$NEXUS_OBJECT_ARTIFACT_ID.$NEXUS_OBJECT_EXTENSION

RUN $HOME/script/maven-search-download.sh

################################################################################
# Production image
################################################################################
FROM $BASE_IMAGE as prod

ARG BASE_IMAGE
ARG POM_GROUP_ID
ARG POM_ARTIFACT_ID
ARG POM_VERSION
LABEL base.image=$BASE_IMAGE
LABEL ibm-mq.version=$POM_GROUP_ID:$POM_ARTIFACT_ID:$POM_VERSION
LABEL wildfly.modules=logstash,oracle-jdbc,ibm-mq

ARG DOWNLOAD_DIR=$HOME/download

ARG WILDFLY_DEPLOYMENTS_DIR=$WILDFLY_HOME/standalone/deployments

COPY --from=download --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP ${DOWNLOAD_DIR}/wmq.jakarta.jmsra.rar ${WILDFLY_DEPLOYMENTS_DIR}/wmq.jakarta.jmsra.rar
