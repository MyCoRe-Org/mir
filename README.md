# MIR [![Build Status](https://travis-ci.org/MyCoRe-Org/mir.svg?branch=master)](https://travis-ci.org/MyCoRe-Org/mir) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/3005892d274040d8a29e33a080a956d9)](https://www.codacy.com/app/MyCoRe/mir?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=MyCoRe-Org/mir&amp;utm_campaign=Badge_Grade)
MIR (acronym for MyCoRe/MODS Institutional Repository) is an open source repository software that is build upon [MyCoRe](https://github.com/MyCoRe-Org/mycore) and [MODS](http://www.loc.gov/standards/mods/).


## Installation instructions
Detailed instructions you can find on [MIR Documentation site](http://mycore.de/generated/mir)
 - initialize solr configuration using `git submodule update --init --recursive`
 - to start solr, go to mir-webapp
  - install solr with the command: `mvn solr-runner:copyHome`
  - run solr with the command: `mvn solr-runner:start`
  - stop solr with the command: `mvn solr-runner:stop`
  - update solr with the command: `mvn solr-runner:stop solr-runner:copyHome solr-runner:start`
 - to starting up a servlet container in development environment go back to mir folder
  - run `mvn install -am -pl mir-webapp && mvn -Pdev -Djetty org.codehaus.cargo:cargo-maven2-plugin:run -pl mir-webapp` If you want to test the application with Tomcat instead replace `-Djetty` by `-Dtomcat=9`


## Git-Style-Guide
For the moment see [agis-:Git-Style-Guide](https://github.com/agis-/git-style-guide) and use it with the following exceptions:
 - Subject to commits is in form: `{JIRA-Ticket} {Ticket summary} {Commit summary}`, like `MIR-526 Git-Migration add .travis.yml`
 - Branch name to work on a ticket is in form: `issues/{JIRA-Ticket}-{Ticket_Summary}`, like `issues/MIR-526-Git_Migration`

Stay tuned for more information. :bow:
