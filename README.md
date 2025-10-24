# MIR [![Build Status](https://travis-ci.org/MyCoRe-Org/mir.svg?branch=master)](https://travis-ci.org/MyCoRe-Org/mir) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/edf89bf4bb564a56b74aeb3d3e6474a4)](https://www.codacy.com/gh/MyCoRe-Org/mir/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=MyCoRe-Org/mir&amp;utm_campaign=Badge_Grade)
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
 - To start Solr, go to `mir-webapp`
   - Install Solr with the command: `mvn -Pdev solr-runner:copyHome`
   - Run Solr with the command: `mvn -Pdev solr-runner:start`
 - To start up a servlet container as a development environment go back to `mir` folder
   - Run `mvn install -am -pl mir-webapp && mvn -Pdev -Dtomcat org.codehaus.cargo:cargo-maven3-plugin:run -pl mir-webapp`
   - Open `http://localhost:8291/mir` in your browser
 - To perform the guided initial configuration
   - Use the login token from the server log to continue
   - Use the SOLR server URL `http://localhost:8983`
   - Use main core name `mir` and classification core name `mir-classifications`
   - Check "Create cores in Solr server via SolrCloud API"
   - Check "Configure a user for Solr administration", "indexing in Solr" and "searching in Solr"
   - Enter usernames `admin`, `indexer` and `searcher` respectively and password `alleswirdgut` for all three users
   - Select database type `H2`
   - Continue and restart the servlet container as instructed
   - Open `http://localhost:8291/mir` in your browser again
   - Log in using username `administrator` and password `alleswirdgut`

Afterward, you can stop Solr from the `mir-webapp` folder with `mvn -Pdev solr-runner:stop`.
If you need to update Solr cores, you can do this from the `mir-webapp` folder with `mvn -Pdev solr-runner:stop solr-runner:copyHome solr-runner:start`.

**Notice**

When switching from the 2023.06 branch to a newer version, make sure to run the following command to remove deprecated submodules from `mir-webapp/src/main`:
```
git submodule deinit --all
```

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

## `mir` Docker-Container
The docker container has its own install script which uses the environment variables.

### Environment Variables
| Property                 | Default,  required  | Description                                                                                                                                                                                                                                                                          |
|--------------------------|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ENABLE_SOLR_CLOUD        | false               | If true the Solr Cloud mode is enabled. (solr cores will be created on install)                                                                                                                                                                                                      |
| SOLR_ADMIN_USER          | none                | The username for the Solr Admin. (will be used for admin commands like creating cores)                                                                                                                                                                                               |
| SOLR_ADMIN_PASSWORD      | none                | The password for the Solr Admin.                                                                                                                                                                                                                                                     |
| SOLR_INDEX_USER          | none                | The username for the Solr Indexer. (will be used for indexing)                                                                                                                                                                                                                       |
| SOLR_INDEX_PASSWORD      | none                | The password for the Solr Indexer.                                                                                                                                                                                                                                                   |
| SOLR_SEARCH_USER         | none                | The username for the Solr Searcher. (will be used for searching)                                                                                                                                                                                                                     |
| SOLR_SEARCH_PASSWORD     | none                | The password for the Solr Searcher.                                                                                                                                                                                                                                                  |
| TIKASERVER_URL           | none                | The URL to the Tika Server. Same as MCR.Solr.Tika.ServerURL in mycore.properties. (also sets `MCR.Solr.FileIndexStrategy` to `org.mycore.solr.index.file.tika.MCRTikaSolrFileStrategy`)                                                                                              |
| SOLR_URL                 | none, required      | The URL to the SOLR Server. Same as MCR.Solr.ServerURL in mycore.properties.                                                                                                                                                                                                         |
| SOLR_CORE                | mir                 | The name of the Solr main core. Same as MCR.Solr.Core.main.Name in mycore.properties.                                                                                                                                                                                                |
| SOLR_CLASSIFICATION_CORE | mir-classifications | The name of the Solr classification core. Same as MCR.Solr.Core.classification.Name in mycore.properties.                                                                                                                                                                            |
| JDBC_NAME                | none, required      | The username for the Database authentication. Same as javax.persistence.jdbc.user in persistence.xml.                                                                                                                                                                                |
| JDBC_PASSWORD            | none, required      | The password for the Database authentication. Same as javax.persistence.jdbc.password in persistence.xml.                                                                                                                                                                            |
| JDBC_DRIVER              | none, required      | The driver for the Database. Same as javax.persistence.jdbc.driver in persistence.xml.   If you use org.postgresql.Driver, org.mariadb.jdbc.Driver, org.hsqldb.jdbcDriver, org.h2.Driver or com.mysql.jdbc.Driver the right database drivers get downloaded by the installer script. |
| JDBC_URL                 | none, required      | The url for the Database.                                                                                                                                                                                                                                                            |
| JDBC_SCHEMA              | public              | The schema for the Database. Same as hibernate.default_schema in persistence.xml.                                                                                                                                                                                                    |
| APP_CONTEXT              | mir                 | The url context in which the app lives. (The .war will be renamed to the $APP_CONTEXT.war)                                                                                                                                                                                           |
| MCR_CONFIG_DIR           | /mcr/home/          | The location for the home directory. Same as the MCR.ConfigDir .                                                                                                                                                                                                                     |
| MCR_DATA_DIR             | /mcr/data/          | The location for the data directory. Same as MCR.datadir in mycore.properties.                                                                                                                                                                                                       |
| XMX                      | 1g                  | The value of the -Xmx parameter for Tomcat.                                                                                                                                                                                                                                          |
| XMS                      | 1g                  | The value of the -Xms parameter for Tomcat.                                                                                                                                                                                                                                          |
| FIX_FILE_SYSTEM_RIGHTS   | false               | If true the file system rights of the mounted volumes get corrected to be owned by the right user.                                                                                                                                                                                   |
| MIR_OPTS                 |                     | Additional options which will be passed as JAVA_OPTS to the tomcat process                                                                                                                                                                                                           |
| Property.&lt;property name&gt;|                | Variables beginning with `Property.` are automatically recognized and added to mycore.properties, e.g., `Property.MyProperty=Value`.                                                                                                                                                 |

### Mount Points

The paths in `MCR_CONFIG_DIR` and `MCR_DATA_DIR` should be mounted. Default values are `/mcr/home/` and `/mcr/data/`.
When starting the container the first time you may receive errors like
`java.io.FileNotFoundException: /mcr/home/mycore.active.properties (Permission denied)` this is because the container 
runs as user `mcr` and the mounted volumes are owned by `root`.
To fix this you can set the docker property `FIX_FILE_SYSTEM_RIGHTS` to `true`. This will change the owner of the
mounted volumes to `mcr` and the container will start without errors.

## `mir-solr` Docker-Container
The docker container starts solr in cloud mode. It preconfigures the users with the environment variables (see table above).

### Mount Points

The path `/var/solr/data` should be mounted, it contains all persistent data.

## Docker-Compose

There is an [example docker-compose.yml](docker-compose.yml) which can be used for local development. 
The ports and other settings can be changed in the [.env file](.env). You can use the commands:
```shell
mvn clean install -Pdev -Dtomcat clean install && docker-compose up --build
```

There is another [example docker-compose.prod.yml](docker-compose.prod.yml) which uses prebuild images which are stored at [dockerhub](https://hub.docker.com/u/mycoreorg). 
You can start them with the commands:
```shell
docker-compose -f docker-compose.prod.yml up
```

It's strongly recommended to add a reverse proxy like Apache or Nginx in front. 

## Git-Style-Guide
For the moment see [agis-:Git-Style-Guide](https://github.com/agis-/git-style-guide) and use it with the following exceptions:
 - Subject to commits is in form: `{JIRA-Ticket} {Ticket summary} {Commit summary}`, like `MIR-526 Git-Migration add .travis.yml`
 - Branch name to work on a ticket is in form: `issues/{JIRA-Ticket}-{Ticket_Summary}`, like `issues/MIR-526-Git_Migration`

Stay tuned for more information. :bow:
