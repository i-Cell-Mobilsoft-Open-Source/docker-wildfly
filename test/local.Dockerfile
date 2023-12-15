# docker-compose adja
ARG WILDFLY_BASE_IMAGE

################################################################################
# Default image customization
################################################################################
FROM ${WILDFLY_BASE_IMAGE} as base

ARG TMP_DIR=$HOME/tmp
ARG WILDFLY_CLI_PATH
#ARG PERSISTENCE_HIBERNATE_DIALECT

#ENV HIBERNATE_DIALECT=$PERSISTENCE_HIBERNATE_DIALECT

#remove json logging, set console log
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP \
    ${WILDFLY_CLI_PATH}/*.* \
    $TMP_DIR/embed-server/

RUN set -x; \
    echo "TMP_DIR=$TMP_DIR" >> $TMP_DIR/wf.properties && \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/embed-server/embed-server.cli \
        --properties=$TMP_DIR/wf.properties && \
    rm -rf ${TMP_DIR} && \
    rm -rf $WILDFLY_HOME/standalone/configuration/standalone_xml_history


## set jmx
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP \
    scripts/jmx.sh ${WILDFLY_HOME}/config/jmx.sh
RUN ${WILDFLY_HOME}/config/jmx.sh

# Expose the ports we're interested in
EXPOSE 8080 9990 8787

#CMD ["${WILDFLY_HOME}/bin/standalone.sh -P $WILDFLY_PROPERTIES_FILE -b 0.0.0.0 -bmanagement 0.0.0.0 --debug *:8787"]
