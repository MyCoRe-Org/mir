FROM tomcat:jdk17-temurin-focal
EXPOSE 8080
EXPOSE 8009
WORKDIR /usr/local/tomcat/
ARG PACKET_SIZE="65536"
ENV APP_CONTEXT="mir"
ENV MCR_CONFIG_DIR="/mcr/home/"
ENV MCR_DATA_DIR="/mcr/data/"
ENV SOLR_CORE="mir"
ENV SOLR_CLASSIFICATION_CORE="mir-classifications"
ENV XMX="1g"
ENV XMS="1g"
COPY --from=regreb/bibutils --chown=root:root /usr/local/bin/* /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/mir.sh
RUN ["chmod", "+x", "/usr/local/bin/mir.sh"]
RUN rm -rf /usr/local/tomcat/webapps/*
RUN mkdir /opt/mir/
RUN sed -ri "s/<\/Service>/<Connector protocol=\"AJP\/1.3\" packetSize=\"$PACKET_SIZE\" tomcatAuthentication=\"false\" scheme=\"https\" secretRequired=\"false\" allowedRequestAttributesPattern=\".*\" encodedSolidusHandling=\"decode\" address=\"0.0.0.0\" port=\"8009\" redirectPort=\"8443\" \/>&/g" /usr/local/tomcat/conf/server.xml
COPY --chown=root:root mir-webapp/target/mir-*.war /opt/mir/mir.war
COPY --chown=root:root mir-cli/target/mir-*.tar.gz /opt/mir/mir.tar.gz
RUN cd /opt/mir/ && tar -zxf /opt/mir/mir.tar.gz && /bin/sh -c "mv mir-cli-* mir"
CMD ["bash", "/usr/local/bin/mir.sh"]
