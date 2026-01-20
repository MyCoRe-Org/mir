FROM solr:9.10
USER root
RUN apt-get update && \
    apt-get -y install sudo
COPY --chown=root:root docker-entrypoint.sh ./
RUN chmod 555 docker-entrypoint.sh
CMD ["bash", "docker-entrypoint.sh"]
