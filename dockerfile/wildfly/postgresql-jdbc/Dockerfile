# coming from docker-compose
ARG BASE_IMAGE
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
# Production image
################################################################################
FROM $BASE_IMAGE as prod

ARG BASE_IMAGE
ARG POM_GROUP_ID
ARG POM_ARTIFACT_ID
ARG POM_VERSION
LABEL base.image=$BASE_IMAGE
LABEL postgresql-jdbc.version=$POM_GROUP_ID:$POM_ARTIFACT_ID:$POM_VERSION
LABEL wildfly.modules=logstash,postgresql-jdbc
LABEL hibernate-dialect=org.hibernate.dialect.PostgreSQL95Dialect

ARG TMP_DIR=$HOME/tmp
ARG DOWNLOAD_DIR=$HOME/download

COPY --from=download --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP ${DOWNLOAD_DIR}/ ${TMP_DIR}/
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP dockerfile/script/wildfly-cli/module/postgresql-jdbc.cli $TMP_DIR/module/postgresql-jdbc.cli
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP \
    dockerfile/script/wildfly-cli/embed-server/add-postgresql-datasource.cli \
    dockerfile/script/wildfly-cli/embed-server/configure-property-replacement.cli \
    dockerfile/script/wildfly-cli/embed-server/add-postgresql-driver.cli \
    dockerfile/wildfly/postgresql-jdbc/embed-server.cli \
    $TMP_DIR/embed-server/

RUN set -x; \
    echo "POSTGRESQL_JDBC_RESOURCES=$TMP_DIR/postgresql.jar" >> $TMP_DIR/wf.properties; \
    echo "TMP_DIR=$TMP_DIR" >> $TMP_DIR/wf.properties && \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/module/postgresql-jdbc.cli \
        --properties=$TMP_DIR/wf.properties; \
    $WILDFLY_HOME/bin/jboss-cli.sh \
        --file=$TMP_DIR/embed-server/embed-server.cli \
        --properties=$TMP_DIR/wf.properties && \
    rm -rf ${TMP_DIR} && \
    rm -rf $WILDFLY_HOME/standalone/configuration/standalone_xml_history

##Default dialect for postgresql
ARG PERSISTENCE_HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQL95Dialect
ENV HIBERNATE_DIALECT=$PERSISTENCE_HIBERNATE_DIALECT
