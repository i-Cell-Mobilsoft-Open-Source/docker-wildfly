# coming from docker-compose
ARG BASE_IMAGE
ARG ARTIFACT_DOWNLOADER_IMAGE

################################################################################
# Download .jar
################################################################################
FROM $ARTIFACT_DOWNLOADER_IMAGE as download

ARG POM_OJDBC_GROUP_ID
ARG POM_OJDBC_ARTIFACT_ID
ARG POM_OJDBC_VERSION
ARG POM_OJDBC_EXTENSION

ENV NEXUS_OBJECT_GROUP_ID=$POM_OJDBC_GROUP_ID
ENV NEXUS_OBJECT_ARTIFACT_ID=$POM_OJDBC_ARTIFACT_ID
ENV NEXUS_OBJECT_VERSION=$POM_OJDBC_VERSION
ENV NEXUS_OBJECT_EXTENSION=$POM_OJDBC_EXTENSION

ENV NEXUS_DOWNLOAD_OUTPUT_FILE_NAME=$NEXUS_OBJECT_ARTIFACT_ID.$NEXUS_OBJECT_EXTENSION

RUN $HOME/script/maven-search-download.sh

ARG POM_ORAI18N_GROUP_ID
ARG POM_ORAI18N_ARTIFACT_ID
ARG POM_ORAI18N_VERSION
ARG POM_ORAI18N_EXTENSION

ENV NEXUS_OBJECT_GROUP_ID=$POM_ORAI18N_GROUP_ID
ENV NEXUS_OBJECT_ARTIFACT_ID=$POM_ORAI18N_ARTIFACT_ID
ENV NEXUS_OBJECT_VERSION=$POM_ORAI18N_VERSION
ENV NEXUS_OBJECT_EXTENSION=$POM_ORAI18N_EXTENSION

ENV NEXUS_DOWNLOAD_OUTPUT_FILE_NAME=$NEXUS_OBJECT_ARTIFACT_ID.$NEXUS_OBJECT_EXTENSION

RUN $HOME/script/maven-search-download.sh

################################################################################
# Production image
################################################################################
FROM $BASE_IMAGE as prod

ARG BASE_IMAGE
ARG POM_OJDBC_GROUP_ID
ARG POM_OJDBC_ARTIFACT_ID
ARG POM_OJDBC_VERSION
ARG POM_ORAI18N_GROUP_ID
ARG POM_ORAI18N_ARTIFACT_ID
ARG POM_ORAI18N_VERSION
LABEL base.image=$BASE_IMAGE
LABEL oracle-jdbc.version=$POM_OJDBC_GROUP_ID:$POM_OJDBC_ARTIFACT_ID:$POM_OJDBC_VERSION,$POM_ORAI18N_GROUP_ID:$POM_ORAI18N_ARTIFACT_ID:$POM_ORAI18N_VERSION
LABEL wildfly.modules=logstash,oracle-jdbc
LABEL hibernate-dialect=org.hibernate.dialect.OracleDialect

ARG TMP_DIR=$HOME/tmp
ARG DOWNLOAD_DIR=$HOME/download

COPY --from=download --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP ${DOWNLOAD_DIR}/ ${TMP_DIR}/
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP dockerfile/script/wildfly-cli/module/oracle-jdbc.cli $TMP_DIR/module/oracle-jdbc.cli
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP \
    dockerfile/script/wildfly-cli/embed-server/add-oracle-datasource.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-property-replacement.cli \
    dockerfile/script/wildfly-cli/embed-server/add-oracle-driver.cli \
    dockerfile/wildfly/oracle-jdbc/embed-server.cli \
    $TMP_DIR/embed-server/

RUN set -x; \
    echo "ORACLE_JDBC_RESOURCES=$TMP_DIR/ojdbc11.jar,$TMP_DIR/orai18n.jar" >> $TMP_DIR/wf.properties && \
    echo "TMP_DIR=$TMP_DIR" >> $TMP_DIR/wf.properties && \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/module/oracle-jdbc.cli \
        --properties=$TMP_DIR/wf.properties && \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/embed-server/embed-server.cli \
        --properties=$TMP_DIR/wf.properties && \
    rm -rf ${TMP_DIR} && \
    rm -rf $WILDFLY_HOME/standalone/configuration/standalone_xml_history

