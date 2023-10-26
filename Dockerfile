FROM docker.elastic.co/logstash/logstash:8.10.1

ENV VERSION=8.10.1

ENV PIPELINE_WORKERS=2
ENV MONITORING_ENABLED=false
ENV HTTP_HOST=127.0.0.1
ENV MONITORING_ELASTICSEARCH_HOSTS=https://<es_host>:9200
ENV MONITORING_ENABLED=false
ENV NODE_NAME=<node_name>
ENV PATH_DATA=/usr/share/logstash/data
ENV PATH_LOGS=/usr/share/logstash/logs
ENV PIPELINE_ID=<pipeline_name>

RUN rm -f /usr/share/logstash/pipeline/logstash.conf

RUN mkdir /usr/share/logstash/certs
COPY --chmod=755 elasticsearch-ca.pem /usr/share/logstash/certs

USER root
RUN apt-get install -y sudo
############## Install Metricbeat ################
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-${VERSION}-amd64.deb
RUN sudo dpkg -i metricbeat-${VERSION}-amd64.deb
RUN rm metricbeat-${VERSION}-amd64.deb

############## Install Filebeat ###################
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${VERSION}-amd64.deb
RUN sudo dpkg -i filebeat-${VERSION}-amd64.deb
RUN rm filebeat-${VERSION}-amd64.deb

# Copy the certificate and key to the config files
COPY --chmod=755 elasticsearch-ca.pem /etc/metricbeat/
COPY --chmod=755 elasticsearch-ca.pem /etc/filebeat/

# Enable Metricbeat module to monitor Logstash
RUN metricbeat modules enable logstash-xpack
RUN metricbeat modules disable system

# Remove and copy over the custom configurations for Metricbeat
RUN rm -f /etc/metricbeat/metricbeat.yml
RUN rm -f /etc/metricbeat/modules.d/logstash-xpack.yml
COPY --chmod=755 metricbeat/metricbeat.yml /etc/metricbeat/
COPY --chmod=755 metricbeat/logstash-xpack.yml /etc/metricbeat/modules.d/

# Enable Filebeat module to monitor Logstash logs
RUN filebeat modules enable logstash
RUN filebeat modules disable system

# Remove and copy over the custom configurations for Filebeat
RUN rm -f /etc/filebeat/filebeat.yml
RUN rm -f /etc/filebeat/modules.d/logstash.yml
COPY --chmod=755 filebeat/filebeat.yml /etc/filebeat/
COPY --chmod=755 filebeat/logstash.yml /etc/filebeat/modules.d/

# Remove the default log4j2.properties file and copy the custom one to the container
RUN rm -f /usr/share/logstash/config/log4j2.properties
COPY --chmod=644 log4j2.properties /usr/share/logstash/config
RUN chown logstash:root /usr/share/logstash/config/log4j2.properties

WORKDIR /usr/share/logstash

# Move the shell script to the container. It has the commands to run and start the services
COPY --chmod=750 start-services.sh /usr/share/logstash/

# Start Logstash, Metricbeat and Filebeat using the shell script
CMD ["/usr/share/logstash/start-services.sh"]
