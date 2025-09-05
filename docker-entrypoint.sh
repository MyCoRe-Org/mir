#!/usr/bin/bash
set -e

MCR_SAVE_DIR="${MCR_CONFIG_DIR}save/"

MCR_CONFIG_DIR_ESCAPED=$(echo "$MCR_CONFIG_DIR" | sed 's/\//\\\//g')

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

    else
      echo "No c3p0 driver found. Skip migration."
    fi
}


function setOrAddProperty() {
    KEY=$1
    VALUE=$2

    if [ -z "$VALUE" ]; then
      # remove property
      sed -ri "/$KEY/d" "${MYCORE_PROPERTIES}"
      return
    elif [ -z "$KEY" ]; then
      echo "No Key given. Skip setting property."
      return
    fi

    if grep -q "$KEY=" "${MYCORE_PROPERTIES}" ; then
      ESCAPED_KEY=$(echo "${KEY}" | sed 's/\//\\\//g')
      ESCAPED_VALUE=$(echo "${VALUE}" | sed 's/\//\\\//g')
      sed -ri "s/#*($ESCAPED_KEY=).+/\1$ESCAPED_VALUE/" "${MYCORE_PROPERTIES}"
    else
      echo "$KEY=$VALUE">>"${MYCORE_PROPERTIES}"
    fi
}

function setDockerValues() {
    echo "Set Docker Values to Config!"

    if [ -n "${SOLR_URL}" ]; then
      setOrAddProperty "MCR.Solr.ServerURL" "${SOLR_URL}"
    fi

    if [ -n "${SOLR_CORE}" ]; then
      setOrAddProperty "MCR.Solr.Core.main.Name" "${SOLR_CORE}"
    fi

    if [ -n "${SOLR_CLASSIFICATION_CORE}" ]; then
      setOrAddProperty "MCR.Solr.Core.classification.Name" "${SOLR_CLASSIFICATION_CORE}"
    fi

    if [ -n "${JDBC_NAME}" ]; then
      setOrAddProperty "MCR.JPA.User" "${JDBC_NAME}"
    fi

    if [ -n "${JDBC_PASSWORD}" ]; then
      setOrAddProperty "MCR.JPA.Password" "${JDBC_PASSWORD}"
    fi

    if [ -n "${JDBC_DRIVER}" ]; then
      setOrAddProperty "MCR.JPA.Driver" "${JDBC_DRIVER}"
    fi

    if [ -n "${JDBC_URL}" ]; then
      setOrAddProperty "MCR.JPA.URL" "${JDBC_URL}"
    fi

    if [ -n "${JDBC_SCHEMA}" ]; then
      setOrAddProperty "MCR.JPA.DefaultSchema" "${JDBC_SCHEMA}"
    fi

    if [ -n "${SOLR_ADMIN_USER}" ]; then
          setOrAddProperty "MCR.Solr.Server.Auth.Admin.Class" "org.mycore.solr.auth.MCRSolrPropertyBasicAuthenticator"
          setOrAddProperty "MCR.Solr.Server.Auth.Admin.Username" "${SOLR_ADMIN_USER}"
          setOrAddProperty "MCR.Solr.Server.Auth.Admin.Password" "${SOLR_ADMIN_PASSWORD}"
    else
          setOrAddProperty "MCR.Solr.Server.Auth.Admin.Class"
          setOrAddProperty "MCR.Solr.Server.Auth.Admin.Username"
          setOrAddProperty "MCR.Solr.Server.Auth.Admin.Password"
    fi


    if [ -n "${SOLR_INDEX_USER}" ]; then
          setOrAddProperty "MCR.Solr.Server.Auth.Index.Class" "org.mycore.solr.auth.MCRSolrPropertyBasicAuthenticator"
          setOrAddProperty "MCR.Solr.Server.Auth.Index.Username" "${SOLR_INDEX_USER}"
          setOrAddProperty "MCR.Solr.Server.Auth.Index.Password" "${SOLR_INDEX_PASSWORD}"
    else
          setOrAddProperty "MCR.Solr.Server.Auth.Index.Class"
          setOrAddProperty "MCR.Solr.Server.Auth.Index.Username"
          setOrAddProperty "MCR.Solr.Server.Auth.Index.Password"
    fi

    if [ -n "${SOLR_SEARCH_USER}" ]; then
          setOrAddProperty "MCR.Solr.Server.Auth.Search.Class" "org.mycore.solr.auth.MCRSolrPropertyBasicAuthenticator"
          setOrAddProperty "MCR.Solr.Server.Auth.Search.Username" "${SOLR_SEARCH_USER}"
          setOrAddProperty "MCR.Solr.Server.Auth.Search.Password" "${SOLR_SEARCH_PASSWORD}"
    else
          setOrAddProperty "MCR.Solr.Server.Auth.Search.Class"
          setOrAddProperty "MCR.Solr.Server.Auth.Search.Username"
          setOrAddProperty "MCR.Solr.Server.Auth.Search.Password"
    fi

    if [ -n "${TIKASERVER_URL}" ]; then
      setOrAddProperty "MCR.Solr.Tika.ServerURL" "${TIKASERVER_URL}"
      setOrAddProperty "MCR.Solr.FileIndexStrategy" "org.mycore.solr.index.file.tika.MCRTikaSolrFileStrategy"
    else
      setOrAddProperty "MCR.Solr.Tika.ServerURL"
      setOrAddProperty "MCR.Solr.FileIndexStrategy"
    fi

    setOrAddProperty "MCR.JPA.Hbm2ddlAuto" "update"
    setOrAddProperty "MCR.JPA.PersistenceUnit.mir.Class" "org.mycore.backend.jpa.MCRSimpleConfigPersistenceUnitDescriptor"
    setOrAddProperty "MCR.JPA.PersistenceUnitName" "mir"

    setOrAddProperty "MCR.datadir" "${MCR_DATA_DIR}"
    setOrAddProperty "MCR.Solr.NestedDocuments" "true"
    setOrAddProperty "MCR.Save.FileSystem" "${MCR_SAVE_DIR}"

    # s/(<\/properties>)/<property name=\"hibernate.hikari.maximumPoolSize\" value=\"30\" \/>\n<property name=\"hibernate.hikari.minimumIdle\" value=\"2\" \/>\n<property name=\"hibernate.hikari.idleTimeout\" value=\"30000\" \/>\n<property name=\"hibernate.hikari.maxLifetime\" value=\"1800000\" \/>\n<property name=\"hibernate.hikari.leakDetectionThreshold\" value=\"9000\" \/>\n<property name=\"\" value=\"true\" \/>
    setOrAddProperty "MCR.JPA.Connection.ProviderClass" "org.hibernate.hikaricp.internal.HikariCPConnectionProvider"
    setOrAddProperty "MCR.JPA.Connection.MaximumPoolSize" "30"
    setOrAddProperty "MCR.JPA.Connection.MinimumIdle" "2"
    setOrAddProperty "MCR.JPA.Connection.IdleTimeout" "30000"
    setOrAddProperty "MCR.JPA.Connection.MaxLifetime" "180000"
    setOrAddProperty "MCR.JPA.Connection.LeakDetectionThreshold" "9000"
    setOrAddProperty "MCR.JPA.Connection.RegisterMbeans" "true"


    migrateC3P0toHikari

    case $JDBC_DRIVER in
      org.postgresql.Driver) downloadDriver "https://jdbc.postgresql.org/download/postgresql-42.7.0.jar";;
      org.mariadb.jdbc.Driver) downloadDriver "https://repo.maven.apache.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.0/mariadb-java-client-3.3.0.jar";;
      org.h2.Driver) downloadDriver "https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar";;
      com.mysql.jdbc.Driver) downloadDriver "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.2.0/mysql-connector-j-8.2.0.jar";;
    esac

    mkdir -p "${MCR_CONFIG_DIR}lib"

    downloadDriver https://repo1.maven.org/maven2/com/zaxxer/HikariCP/5.1.0/HikariCP-5.1.0.jar

    # iterate over all environment variables starting with MCR.JPA. and add them to the mycore.properties
    for var in $(env | grep -E "^MCR.JPA."); do
      key=$(echo $var | cut -d'=' -f1 | sed 's/MCR.JPA.//g')
      value=$(echo $var | cut -d'=' -f2)
      complete_key="MCR.JPA.$key"

      setOrAddProperty "$complete_key" "$value"
    done

    rm -f "${PERSISTENCE_XML}"
}

function setUpMyCoRe {
    echo "Set up MyCoRe!"
    /opt/mir/mir/bin/mir.sh create configuration directory
    setDockerValues
    setupLog4jConfig

    # ENABLE_SOLR_CLOUD
    if [[ "$ENABLE_SOLR_CLOUD" == "true" ]]
    then
      echo "upload local config set for main" >> "${MCR_CONFIG_DIR}setup-solr-cloud.txt"
      echo "upload local config set for classification" >> "${MCR_CONFIG_DIR}setup-solr-cloud.txt"
      echo "create collection for core main" >> "${MCR_CONFIG_DIR}setup-solr-cloud.txt"
      echo "create collection for core classification" >> "${MCR_CONFIG_DIR}setup-solr-cloud.txt"
      /opt/mir/mir/bin/mir.sh process /mcr/home/setup-solr-cloud.txt
    fi

    /opt/mir/mir/bin/setup.sh
}

sed -ri "s/(-DMCR.AppName=).+( \\\\)/\-DMCR.ConfigDir=${MCR_CONFIG_DIR_ESCAPED}\2/" /opt/mir/mir/bin/mir.sh
sed -ri "s/(-DMCR.ConfigDir=).+( \\\\)/\-DMCR.ConfigDir=${MCR_CONFIG_DIR_ESCAPED}\2/" /opt/mir/mir/bin/mir.sh

[ "$(ls -A "$MCR_CONFIG_DIR")" ] && setDockerValues || setUpMyCoRe

rm -rf /usr/local/tomcat/webapps/*
cp /opt/mir/mir.war "/usr/local/tomcat/webapps/${APP_CONTEXT}.war"

export JAVA_OPTS="-DMCR.ConfigDir=${MCR_CONFIG_DIR} -Xmx${XMX} -Xms${XMS} ${MIR_OPTS}"
catalina.sh run
