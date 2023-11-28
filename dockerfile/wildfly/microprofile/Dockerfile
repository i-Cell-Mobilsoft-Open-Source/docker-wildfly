# coming from docker-compose
ARG BASE_IMAGE

################################################################################
# Production image
################################################################################
FROM ${BASE_IMAGE} as prod

ARG BASE_IMAGE

LABEL base.image=$BASE_IMAGE
LABEL microprofile.configs=opentrace,metrics,reactive-messaging
LABEL ee.configs=managed-executor

ARG TMP_DIR=$HOME/tmp
ARG DOWNLOAD_DIR=$HOME/download

COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP \
    dockerfile/script/wildfly-cli/embed-server/configure-managed-executor.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-opentracing.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-metrics.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-undertow.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-reactive-messaging.cli \
    dockerfile/wildfly/microprofile/embed-server.cli \
    $TMP_DIR/embed-server/

RUN set -x; \
    echo "TMP_DIR=$TMP_DIR" >> $TMP_DIR/wf.properties && \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/embed-server/embed-server.cli \
        --properties=$TMP_DIR/wf.properties && \
    rm -rf ${TMP_DIR} && \
    rm -rf $WILDFLY_HOME/standalone/configuration/standalone_xml_history
