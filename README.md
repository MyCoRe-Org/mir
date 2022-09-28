# MIR [![Build Status](https://travis-ci.org/MyCoRe-Org/mir.svg?branch=master)](https://travis-ci.org/MyCoRe-Org/mir) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/3005892d274040d8a29e33a080a956d9)](https://www.codacy.com/app/MyCoRe/mir?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=MyCoRe-Org/mir&amp;utm_campaign=Badge_Grade)
MIR (acronym for MyCoRe/MODS Institutional Repository) is an open source repository software that is build upon [MyCoRe](https://github.com/MyCoRe-Org/mycore) and [MODS](http://www.loc.gov/standards/mods/).


## Installation instructions for developer
Detailed instructions for application usage you can find on [MIR Documentation site](https://www.mycore.de/documentation/apps/mir/mir_install/).

This guide addresses developers. Thats why you run it in 'dev' profile!
 - run `mvn clean install -am -pl mir-webapp` in mir folder
 - add profile `dev` to your `.m2/settings.xml` including path to solr home and solr data  
```
    <profile>
      <id>dev</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <mir.solr.home>${user.home}/.mycore/dev-mir/data/solr</mir.solr.home>
        <mir.solr.data.dir>${user.home}/.mycore/dev-mir/data/solr/data</mir.solr.data.dir>
      </properties>
    </profile>
```
 - initialize solr configuration using `git submodule update --init --recursive`
 - to start solr, go to mir-webapp
  - install solr with the command: `mvn -Pdev solr-runner:copyHome`
  - run solr with the command: `mvn -Pdev solr-runner:start`
  - stop solr with the command: `mvn -Pdev solr-runner:stop`
  - update solr with the command: `mvn -Pdev solr-runner:stop solr-runner:copyHome solr-runner:start`
 - to starting up a servlet container in development environment go back to mir folder
  - run `mvn install -am -pl mir-webapp && mvn -Pdev -Djetty org.codehaus.cargo:cargo-maven2-plugin:run -pl mir-webapp` If you want to test the application with Tomcat instead replace `-Djetty` by `-Dtomcat=9`

## Docker-Container
The docker container has its own install script which uses the environment variables. 

### Environment Variables
| Property                 | Default,  required  | Description                                                                                                                                                                                                                                                                          |
|--------------------------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SOLR_URL                 | none, required      | The URL to the SOLR Server. Same as MCR.Solr.ServerURL in mycore.properties.                                                                                                                                                                                                         |
| SOLR_CORE                | mir                 | The name of the Solr main core. Same as MCR.Solr.Core.main.Name in mycore.properties.                                                                                                                                                                                                |
| SOLR_CLASSIFICATION_CORE | mir-classifications | The name of the Solr classification core. Same as MCR.Solr.Core.classification.Name in mycore.properties.                                                                                                                                                                            |
| JDBC_NAME                | none, required      | The username for the Database authentication. Same as javax.persistence.jdbc.user in persistence.xml.                                                                                                                                                                                |
| JDBC_PASSWORD            | none, required      | The password for the Database authentication. Same as javax.persistence.jdbc.password in persistence.xml.                                                                                                                                                                            |
| JDBC_DRIVER              | none, required      | The driver for the Database. Same as javax.persistence.jdbc.driver in persistence.xml.   If you use org.postgresql.Driver, org.mariadb.jdbc.Driver, org.hsqldb.jdbcDriver, org.h2.Driver or com.mysql.jdbc.Driver the right database drivers get downloaded by the installer script. |
| JDBC_URL                 | none, required      | The schema for the Database. Same as hibernate.default_schema in persistence.xml.                                                                                                                                                                                                    |
| APP_CONTEXT              | mir                 | The url context in which the app lifes. (The .war will be renamed to the $APP_CONTEXT.war)                                                                                                                                                                                           |
| MCR_CONFIG_DIR           | /mcr/home/          | The location for the home directory. Same as the MCR.ConfigDir .                                                                                                                                                                                                                     |
| MCR_DATA_DIR             | /mcr/data/          | The location for the data directory. Same as MCR.datadir in mycore.properties.                                                                                                                                                                                                       |
| XMX                      | 1g                  | The value of the -Xmx parameter for Tomcat.                                                                                                                                                                                                                                          |
| XMS                      | 1g                  | The value of the -Xms parameter for Tomcat.                                                                                                                                                                                                                                          |

### Mount Points

The paths in `MCR_CONFIG_DIR` and `MCR_DATA_DIR` should be mountet. Default values are /mcr/home/ and /mcr/data/.

## FAQ
 1. Installation hangs while generating secret  
    There is entropy missing for GPG key generation. For ubuntu eg. you can use rng-tools:  
    `apt-get install rng-tools`  
    `rngd -r /dev/urandom`
 1. Can't export using bibtex button on metadata page  
    install [bibutils](https://sourceforge.net/projects/bibutils/)
 1. How can I use MyCoRe command line interface (not WebCLI)?  
    `mir-cli/target/appassembler/bin/mir.sh`  
    Set `JAVA_OPTS` environment variable to `-DMCR.DataPrefix=dev` before running.
 1. How can I get more than one connection to h2?  
    add `;AUTO_SERVER=TRUE` in jdbc url (configured in persistence.xml)

## Git-Style-Guide
For the moment see [agis-:Git-Style-Guide](https://github.com/agis-/git-style-guide) and use it with the following exceptions:
 - Subject to commits is in form: `{JIRA-Ticket} {Ticket summary} {Commit summary}`, like `MIR-526 Git-Migration add .travis.yml`
 - Branch name to work on a ticket is in form: `issues/{JIRA-Ticket}-{Ticket_Summary}`, like `issues/MIR-526-Git_Migration`

Stay tuned for more information. :bow:
