FROM tomcat:10-jdk17-temurin-jammy
RUN groupadd -r mcr -g 501 && \
    useradd -d /home/mcr -u 501 -m -s /bin/bash -g mcr mcr
WORKDIR /usr/local/tomcat/
ARG PACKET_SIZE="65536"
ARG MAX_PARAMETER_COUNT="1000"
ARG MAX_PART_COUNT="100"
ENV APP_CONTEXT="mir" \
 MCR_CONFIG_DIR="/mcr/home/" \
 MCR_DATA_DIR="/mcr/data/" \
 MCR_LOG_DIR="/mcr/logs/" \
 SOLR_CORE="mir" \
 SOLR_CLASSIFICATION_CORE="mir-classifications" \
 XMX="1g" \
 XMS="1g"
COPY --from=regreb/bibutils --chown=mcr:mcr /usr/local/bin/* /usr/local/bin/
COPY --chown=root:root docker-entrypoint.sh /usr/local/bin/mir.sh
RUN set -eux; \
    chmod 555 /usr/local/bin/mir.sh; \
	apt-get update; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*;
RUN chmod +x /usr/local/bin/mir.sh  && \
    rm -rf /usr/local/tomcat/webapps/* && \
    mkdir /opt/mir/ && \
    chown mcr:mcr -R /opt/mir/ && \
    sed -ri "s/<\/Service>/<Connector protocol=\"AJP\/1.3\" packetSize=\"$PACKET_SIZE\" maxParameterCount=\"$MAX_PARAMETER_COUNT\" maxPartCount=\"$MAX_PART_COUNT\" tomcatAuthentication=\"false\" scheme=\"https\" secretRequired=\"false\" allowedRequestAttributesPattern=\".*\" encodedSolidusHandling=\"decode\" address=\"0.0.0.0\" port=\"8009\" redirectPort=\"8443\" \/>&/g" /usr/local/tomcat/conf/server.xml
COPY --chown=mcr:mcr mir-webapp/target/mir-*.war /opt/mir/mir.war
COPY --chown=mcr:mcr mir-cli/target/mir-*.tar.gz /opt/mir/mir.tar.gz
COPY --chown=mcr:mcr docker-log4j2.xml /opt/mir/log4j2.xml
RUN cd /opt/mir/ &&  \
    tar -zxf /opt/mir/mir.tar.gz && \
    /bin/sh -c "mv mir-cli-* mir" && \
    chown mcr:mcr -R /opt/mir/ /usr/local/tomcat/webapps/
CMD ["bash", "/usr/local/bin/mir.sh"]
