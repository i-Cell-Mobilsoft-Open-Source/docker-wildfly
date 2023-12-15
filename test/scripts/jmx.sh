#!/bin/sh

cat >> /$WILDFLY_HOME/bin/standalone.conf <<-END

	# If JMX_PORT set (e.g. docker run -e JMX_PORT=9876 ...)
	# The JMX must be called on the port it is running or it will refuse the connection (so no docker port mapping is possible, use this envvar)
	if [ ! -z "\$JMX_PORT" ]; then

	   # Add jboss logmanager module
	   JBOSS_MODULES_SYSTEM_PKGS="\$JBOSS_MODULES_SYSTEM_PKGS,org.jboss.logmanager"
	   JAVA_OPTS="\$JAVA_OPTS -Djboss.modules.system.pkgs=\$JBOSS_MODULES_SYSTEM_PKGS"

	   # Load jboss-logmanager and wildfly-common lib

       JSON_LIB="$(echo $WILDFLY_HOME/modules/system/layers/base/org/glassfish/jakarta/json/main/jakarta.json-*.jar)"
       JSON_LIB_INTERNAL="$(echo $WILDFLY_HOME/modules/system/layers/base/internal/javax/json/api/ee8/main/jakarta.json-*.jar)"
	   JBOSS_LOG_MANAGER_LIB="$(echo $WILDFLY_HOME/modules/system/layers/base/org/jboss/logmanager/main/jboss-logmanager-*.jar)"
	   JBOSS_COMMON_LIB="$(echo $WILDFLY_HOME/modules/system/layers/base/org/wildfly/common/main/wildfly-common-*.jar)"
	   JAVA_OPTS="\$JAVA_OPTS -Xbootclasspath/a:\$JSON_LIB:\$JSON_LIB_INTERNAL:\$JBOSS_LOG_MANAGER_LIB:\$JBOSS_COMMON_LIB"

	   # Configure logmanager
	   JAVA_OPTS="\$JAVA_OPTS -Djava.util.logging.manager=org.jboss.logmanager.LogManager -Dsun.util.logging.disableCallerCheck=true"

	   # Enable JMX
	   JAVA_OPTS="\$JAVA_OPTS -Dcom.sun.management.jmxremote -Djava.rmi.server.hostname=localhost -Dcom.sun.management.jmxremote.port=\$JMX_PORT -Dcom.sun.management.jmxremote.rmi.port=\$JMX_PORT -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
	fi


END

