ARG BASE_IMAGE
ARG DOCKER_IMAGE_GALLEON
ARG GALLEON_LAYERS

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
ENV WILDFLY_VERSION=$WILDFLY_VERSION
ENV WILDFLY_HOME=$HOME/wildfly
ENV GALLEON_LAYERS=$GALLEON_LAYERS
ENV CONFIG_DIR=$HOME/config
ENV WILDFLY_PROPERTIES_FILE=$CONFIG_DIR/wildfly.properties
ENV LAUNCH_JBOSS_IN_BACKGROUND=true

RUN set -x; \
    mkdir -m u=rwx,g=rwx,o=rx -p $CONFIG_DIR && \
    chown -R $SYSTEM_USER:$SYSTEM_USER_GROUP $CONFIG_DIR && \
    touch $WILDFLY_PROPERTIES_FILE

COPY --from=galleon --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP $WILDFLY_HOME $WILDFLY_HOME

RUN echo "# Icellmobilsoft Java17 custom packages" >> $WILDFLY_HOME/bin/standalone.conf && \
    # we need the additional package due to java17
    ADDITIONAL_JPMS="JAVA_OPTS=\"\$JAVA_OPTS --add-opens=java.base/java.net=ALL-UNNAMED\"" && \
    echo "$ADDITIONAL_JPMS" >> $WILDFLY_HOME/bin/standalone.conf

LABEL base.image=$BASE_IMAGE
LABEL builder.images=$DOCKER_IMAGE_GALLEON
LABEL wildfly.version=$WILDFLY_VERSION
LABEL galleon.image=$DOCKER_IMAGE_GALLEON
LABEL galleon.layers=$GALLEON_LAYERS
LABEL wildfly.properties.file=$WILDFLY_PROPERTIES_FILE

EXPOSE 8080 8443 9990 8787

CMD exec "$WILDFLY_HOME/bin/standalone.sh" -P $WILDFLY_PROPERTIES_FILE -b 0.0.0.0 -bmanagement 0.0.0.0
