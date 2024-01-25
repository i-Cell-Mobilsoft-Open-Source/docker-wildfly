# coming from docker-compose
ARG BASE_IMAGE
ARG DOCKER_IMAGE_GALLEON
ARG GALLEON_LAYERS
ARG ARTIFACT_DOWNLOADER_IMAGE

################################################################################
# Download .jar
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
# galleon image
################################################################################
FROM ${DOCKER_IMAGE_GALLEON} as galleon

ARG GALLEON_LAYERS
ARG WILDFLY_VERSION
ARG WILDFLY_HOME=$HOME/wildfly

RUN --mount=type=cache,target=$GALLEON_HOME/.m2,uid=101,gid=101 \
        if [ "$GALLEON_LAYERS" = "full" ] ; then \
            ${GALLEON_HOME}/bin/galleon.sh install wildfly:current#${WILDFLY_VERSION} \
                --dir=${WILDFLY_HOME} \
                --verbose; \
        else \
            ${GALLEON_HOME}/bin/galleon.sh install wildfly:current#${WILDFLY_VERSION} \
                --layers=${GALLEON_LAYERS} \
                --dir=${WILDFLY_HOME} \
                --verbose; \
        fi ;

################################################################################
# Production image
################################################################################
FROM ${BASE_IMAGE} as prod

ARG BASE_IMAGE
ARG WILDFLY_VERSION
ARG WILDFLY_HOME
ARG DOCKER_IMAGE_GALLEON
ARG GALLEON_LAYERS
ARG DEBUG_PORT="*:8787"

ENV WILDFLY_VERSION=$WILDFLY_VERSION
ENV WILDFLY_HOME=$HOME/wildfly
ENV GALLEON_LAYERS=$GALLEON_LAYERS
ENV CONFIG_DIR=$HOME/config
ENV WILDFLY_PROPERTIES_FILE=$CONFIG_DIR/wildfly.properties
ENV LAUNCH_JBOSS_IN_BACKGROUND=true
ENV DEBUG_PORT=$DEBUG_PORT

ARG POM_GROUP_ID
ARG POM_ARTIFACT_ID
ARG POM_VERSION

ARG TMP_DIR=$HOME/tmp
ARG DOWNLOAD_DIR=$HOME/download

COPY --from=download --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP ${DOWNLOAD_DIR}/ ${TMP_DIR}/
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP dockerfile/script/wildfly-cli/module/logstash.cli $TMP_DIR/module/logstash.cli
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP \
    dockerfile/script/wildfly-cli/embed-server/configure-logging.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-logging-json.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-logging-file.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-logstash.cli \
    dockerfile/wildfly/common/embed-server.cli \
    $TMP_DIR/embed-server/

RUN set -x; \
    mkdir -m u=rwx,g=rwx,o=rx -p $CONFIG_DIR && \
    chown -R $SYSTEM_USER:$SYSTEM_USER_GROUP $CONFIG_DIR && \
    touch $WILDFLY_PROPERTIES_FILE

COPY --from=galleon --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP $WILDFLY_HOME $WILDFLY_HOME

RUN echo "# ironjacamar conf and Icellmobilsoft Java17 custom packages" >> $WILDFLY_HOME/bin/standalone.conf && \
    # we need the additional package due to java17
    ADDITIONAL_JPMS="JAVA_OPTS=\"\$JAVA_OPTS -Dironjacamar.jdbc.setautocommitoncleanup=false --add-opens=java.base/java.net=ALL-UNNAMED\"" && \
    echo "$ADDITIONAL_JPMS" >> $WILDFLY_HOME/bin/standalone.conf

## add logstash module + add 4 handlers
RUN set -x; \
    echo "LOGSTASH_RESOURCES=$TMP_DIR/logstash-gelf.jar" >> $TMP_DIR/wf.properties && \
    echo "TMP_DIR=$TMP_DIR" >> $TMP_DIR/wf.properties && \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/module/logstash.cli \
        --properties=$TMP_DIR/wf.properties && \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/embed-server/embed-server.cli \
        --properties=$TMP_DIR/wf.properties && \
    rm -rf ${TMP_DIR} && \
    rm -rf $WILDFLY_HOME/standalone/configuration/standalone_xml_history

LABEL base.image=$BASE_IMAGE
LABEL builder.images=$DOCKER_IMAGE_GALLEON
LABEL wildfly.modules=logstash
LABEL wildfly.version=$WILDFLY_VERSION
LABEL galleon.image=$DOCKER_IMAGE_GALLEON
LABEL galleon.layers=$GALLEON_LAYERS
LABEL logstash.version=$POM_GROUP_ID:$POM_ARTIFACT_ID:$POM_VERSION
LABEL wildfly.properties.file=$WILDFLY_PROPERTIES_FILE

EXPOSE 8080 8443 9990 4712 4713 9993 8009

CMD exec "$WILDFLY_HOME/bin/standalone.sh" -P $WILDFLY_PROPERTIES_FILE -b 0.0.0.0 -bmanagement 0.0.0.0
