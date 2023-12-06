#!/usr/bin/bash
set -e

MCR_SAVE_DIR="${MCR_CONFIG_DIR}save/"

MCR_CONFIG_DIR_ESCAPED=$(echo "$MCR_CONFIG_DIR" | sed 's/\//\\\//g')
MCR_DATA_DIR_ESCAPED=$(echo "$MCR_DATA_DIR" | sed 's/\//\\\//g')
MCR_SAVE_DIR_ESCAPED=$(echo "$MCR_SAVE_DIR" | sed 's/\//\\\//g')
MCR_LOG_DIR_ESCAPED=$(echo "$MCR_LOG_DIR" | sed 's/\//\\\//g')

SOLR_URL_ESCAPED=$(echo "$SOLR_URL" | sed 's/\//\\\//g')
SOLR_CORE_ESCAPED=$(echo "$SOLR_CORE" | sed 's/\//\\\//g')
SOLR_CLASSIFICATION_CORE_ESCAPED=$(echo "$SOLR_CLASSIFICATION_CORE" | sed 's/\//\\\//g')

JDBC_NAME_ESCAPED=$(echo "$JDBC_NAME" | sed 's/\//\\\//g')
JDBC_PASSWORD_ESCAPED=$(echo "$JDBC_PASSWORD" | sed 's/\//\\\//g')
JDBC_DRIVER_ESCAPED=$(echo "$JDBC_DRIVER" | sed 's/\//\\\//g')
JDBC_URL_ESCAPED=$(echo "$JDBC_URL" | sed 's/\//\\\//g')
HIBERNATE_SCHEMA_ESCAPED=$(echo "$JDBC_URL" | sed 's/\//\\\//g')

MYCORE_PROPERTIES="${MCR_CONFIG_DIR}mycore.properties"
PERSISTENCE_XML="${MCR_CONFIG_DIR}resources/META-INF/persistence.xml"

function fixDirectoryRights() {
  find "$1" \! -user "$2" -exec chown "$2:$2" '{}' +
}

echo "Running MIR Starter Script as User: $(whoami)"

if [ "$EUID" -eq 0 ]
  then
    if [[ "$FIX_FILE_SYSTEM_RIGHTS" == "true" ]]
    then
      echo "Fixing File System Rights"
      fixDirectoryRights "$MCR_CONFIG_DIR" "mcr"
      fixDirectoryRights "$MCR_DATA_DIR" "mcr"
      fixDirectoryRights "$MCR_LOG_DIR" "mcr"
    fi
    exec gosu mcr "$0"
    exit 0;
fi

sleep 5 # wait for database (TODO: replace with wait-for-it)

cd /usr/local/tomcat/

function setupLog4jConfig() {
  if [[ ! -f "${MCR_CONFIG_DIR}resources/log4j2.xml" ]]
  then
    cp /opt/mir/log4j2.xml "${MCR_CONFIG_DIR}resources/"
  fi
}

function downloadDriver {
  FILENAME=$(basename $1)
  if [[ ! -f "${MCR_CONFIG_DIR}lib/${FILENAME}" ]]
  then
    curl -o "${MCR_CONFIG_DIR}lib/${FILENAME}" "$1"
  fi
}

function migrateC3P0toHikari {
    # check if c3p0 is used (if any c3p0-* file present)
    if ls "${MCR_CONFIG_DIR}lib/c3p0-"*.jar 1> /dev/null 2>&1; then
      echo "Migrate from c3p0 to HikariCP"
      # delete old c3p0 drivers
      rm "${MCR_CONFIG_DIR}lib/c3p0-"*.jar
      rm "${MCR_CONFIG_DIR}lib/mchange-commons-java-"*.jar
      rm "${MCR_CONFIG_DIR}lib/hibernate-c3p0-"*.jar

      # delete old database drivers
      rm "${MCR_CONFIG_DIR}lib/postgresql-42.2.9.jar"
      rm "${MCR_CONFIG_DIR}lib/mariadb-java-client-2.5.4.jar"
      rm "${MCR_CONFIG_DIR}lib/h2-1.4.200.jar"
      rm "${MCR_CONFIG_DIR}lib/mysql-connector-java-8.0.19.jar"

      # delete old configuration and add new configuration
      if grep -q "hibernate.c3p0" "${PERSISTENCE_XML}"; then
        sed -ri "s/.*hibernate.c3p0.*//" "${PERSISTENCE_XML}"
        sed -ri "s/(<property name=\"hibernate.connection.provider_class\" value=\")(.*)(\" \/>)/\1org.hibernate.hikaricp.internal.HikariCPConnectionProvider\3/" "${PERSISTENCE_XML}"
        sed -ri "s/(<\/properties>)/<property name=\"hibernate.hikari.maximumPoolSize\" value=\"30\" \/>\n<property name=\"hibernate.hikari.minimumIdle\" value=\"2\" \/>\n<property name=\"hibernate.hikari.idleTimeout\" value=\"30000\" \/>\n<property name=\"hibernate.hikari.maxLifetime\" value=\"1800000\" \/>\n<property name=\"hibernate.hikari.leakDetectionThreshold\" value=\"9000\" \/>\n<property name=\"hibernate.hikari.registerMbeans\" value=\"true\" \/>\n\1/" "${PERSISTENCE_XML}"
      fi

      /opt/mir/mir/bin/mir.sh reload mappings in jpa configuration file
    else
      echo "No c3p0 driver found. Skip migration."
    fi
}

function migrateJavaxPropertiesToJakarta() {
  if grep -q "javax.persistence" "${PERSISTENCE_XML}"; then
    echo "Migrate properties in persistence.xml from javax to jakarta"
    sed -ri "s/(<property name=\")javax.persistence(.*\" value=\".*\" \/>)/\1jakarta.persistence\2/" "${PERSISTENCE_XML}"
  fi
  if grep -q "xmlns.jcp.org" "${PERSISTENCE_XML}"; then
    echo "Migrate xmlns in persistence.xml from jcp.org to jakarta.ee"
    sed -ri "s/xmlns=\".+persistence\"/xmlns=\"https:\/\/jakarta.ee\/xml\/ns\/persistence\"/" "${PERSISTENCE_XML}"
    echo "Migrate schemaLocation in persistence.xml from jcp.org to jakarta.ee"
    grep -ri "s/(xsi:schemaLocation=\").*jcp.org.*(\")/\1https:\/\/jakarta.ee\/xml\/ns\/persistence https:\/\/jakarta.ee\/xml\/ns\/persistence\/persistence_3_0.xsd\2/" "${PERSISTENCE_XML}"
  fi
  if grep -q "version=\"2" "${PERSISTENCE_XML}"; then
    echo "Migrate version in persistence.xml from 2.* to 3.0"
    sed -ri "s/version=\"2.*\"/version=\"3.0\"/" "${PERSISTENCE_XML}"
  fi
}

function setDockerValues() {
    echo "Set Docker Values to Config!"

    migrateJavaxPropertiesToJakarta

    if [ -n "${SOLR_URL}" ]; then
      sed -ri "s/#?(MCR\.Solr\.ServerURL=).+/\1${SOLR_URL_ESCAPED}/" "${MYCORE_PROPERTIES}";
    fi

    if [ -n "${SOLR_CORE}" ]; then
      sed -ri "s/#?(MCR\.Solr\.Core\.main\.Name=).+/\1${SOLR_CORE_ESCAPED}/" "${MYCORE_PROPERTIES}";
    fi

    if [ -n "${SOLR_CLASSIFICATION_CORE}" ]; then
      sed -ri "s/#?(MCR\.Solr\.Core\.classification\.Name=).+/\1${SOLR_CLASSIFICATION_CORE_ESCAPED}/" "${MYCORE_PROPERTIES}"
    fi

    if [ -n "${JDBC_NAME}" ]; then
      sed -ri "s/(name=\"jakarta.persistence.jdbc.user\" value=\").*(\")/\1${JDBC_NAME_ESCAPED}\2/" "${PERSISTENCE_XML}"
    fi

    if [ -n "${JDBC_PASSWORD}" ]; then
      sed -ri "s/(name=\"jakarta.persistence.jdbc.password\" value=\").*(\")/\1${JDBC_PASSWORD_ESCAPED}\2/" "${PERSISTENCE_XML}"
    fi

    if [ -n "${JDBC_DRIVER}" ]; then
      sed -ri "s/(name=\"jakarta.persistence.jdbc.driver\" value=\").*(\")/\1${JDBC_DRIVER_ESCAPED}\2/" "${PERSISTENCE_XML}"
    fi

    if [ -n "${JDBC_URL}" ]; then
      sed -ri "s/(name=\"jakarta.persistence.jdbc.url\" value=\").*(\")/\1${JDBC_URL_ESCAPED}\2/" "${PERSISTENCE_XML}"
    fi

    if [ -n "${SOLR_CLASSIFICATION_CORE}" ]; then
      sed -ri "s/(name=\"hibernate.default_schema\" value=\").*(\")/\1${HIBERNATE_SCHEMA_ESCAPED}\2/" "${PERSISTENCE_XML}"
    fi

    sed -ri "s/(name=\"hibernate.hbm2ddl.auto\" value=\").*(\")/\1update\2/" "${PERSISTENCE_XML}"

    if  grep -q "MCR.datadir=" "${MYCORE_PROPERTIES}" ; then
          sed -ri "s/#?(MCR\.datadir=).+/\1${MCR_DATA_DIR_ESCAPED}/" "${MYCORE_PROPERTIES}"
    else
          echo "MCR.datadir=${MCR_DATA_DIR}">>"${MYCORE_PROPERTIES}"
    fi

    if grep -q "MCR.Solr.NestedDocuments=" "${MYCORE_PROPERTIES}" ; then
      sed -ri "s/#?(MCR\.Solr\.NestedDocuments=).+/\1true/" "${MYCORE_PROPERTIES}"
    else
      echo "MCR.Solr.NestedDocuments=true">>"${MYCORE_PROPERTIES}";
    fi

    if  grep -q "MCR.Save.FileSystem=" "${MYCORE_PROPERTIES}" ; then
          sed -ri "s/#?(MCR\.Save\.FileSystem=).+/\1${MCR_SAVE_DIR_ESCAPED}/" "${MYCORE_PROPERTIES}"
    else
          echo "MCR.Save.FileSystem=${MCR_SAVE_DIR}">>"${MYCORE_PROPERTIES}"
    fi

    migrateC3P0toHikari

    case $JDBC_DRIVER in
      org.postgresql.Driver) downloadDriver "https://jdbc.postgresql.org/download/postgresql-42.7.0.jar";;
      org.mariadb.jdbc.Driver) downloadDriver "https://repo.maven.apache.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.0/mariadb-java-client-3.3.0.jar";;
      org.h2.Driver) downloadDriver "https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar";;
      com.mysql.jdbc.Driver) downloadDriver "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.2.0/mysql-connector-j-8.2.0.jar";;
    esac

    mkdir -p "${MCR_CONFIG_DIR}lib"

    downloadDriver https://repo1.maven.org/maven2/com/zaxxer/HikariCP/5.1.0/HikariCP-5.1.0.jar
}

function setUpMyCoRe {
    echo "Set up MyCoRe!"
    /opt/mir/mir/bin/mir.sh create configuration directory
    setDockerValues
    setupLog4jConfig
    /opt/mir/mir/bin/mir.sh reload mappings in jpa configuration file
    sed -ri "s/(<\/properties>)/<property name=\"hibernate.hikari.maximumPoolSize\" value=\"30\" \/>\n<property name=\"hibernate.hikari.minimumIdle\" value=\"2\" \/>\n<property name=\"hibernate.hikari.idleTimeout\" value=\"30000\" \/>\n<property name=\"hibernate.hikari.maxLifetime\" value=\"1800000\" \/>\n<property name=\"hibernate.hikari.leakDetectionThreshold\" value=\"9000\" \/>\n<property name=\"hibernate.hikari.registerMbeans\" value=\"true\" \/>\n\1/" "${MCR_CONFIG_DIR}resources/META-INF/persistence.xml"
    /opt/mir/mir/bin/setup.sh
}

sed -ri "s/(-DMCR.AppName=).+( \\\\)/\-DMCR.ConfigDir=${MCR_CONFIG_DIR_ESCAPED}\2/" /opt/mir/mir/bin/mir.sh
sed -ri "s/(-DMCR.ConfigDir=).+( \\\\)/\-DMCR.ConfigDir=${MCR_CONFIG_DIR_ESCAPED}\2/" /opt/mir/mir/bin/mir.sh

[ "$(ls -A "$MCR_CONFIG_DIR")" ] && setDockerValues || setUpMyCoRe

rm -rf /usr/local/tomcat/webapps/*
cp /opt/mir/mir.war "/usr/local/tomcat/webapps/${APP_CONTEXT}.war"

export JAVA_OPTS="-DMCR.ConfigDir=${MCR_CONFIG_DIR} -Xmx${XMX} -Xms${XMS} ${MIR_OPTS}"
catalina.sh run
