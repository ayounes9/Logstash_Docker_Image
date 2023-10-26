# Logstash_Docker_Image
Build a custom Docker image to run a Logstash container with Filebeat and Metricbeat

The files included are saved in a directory with the following structure:

Dockerfile
elasticsearch-ca.pem
filebeat/filebeat.yml
filebeat/logstash.yml
log4j2.properties
metricbeat/logstash-xpack.yml
metricbeat/metricbeat.yml
start-services.sh

This custom image lets you run Logstash containers to ingest data to your Elasticsearch cluster, with Filebeat and Metricbeat installed on the container to view logs and metrics of the Logstash instance using the pre-built dashboards and monitoring UI in Kibana.

Download the files and adjust the settings based on your environment; the Elasticsearch hosts, Kibana, usernames and passwords.

Docker commands to build and run the container:
Use "." at the end to point to the current directory where Dockerfile exists:
$ docker build -t image_name .

$ docker run -d -p 5044:5044/udp -v /path/to/your/logstash.conf:/usr/share/logstash/pipeline/logstash.conf --name container_name image_name

Check out my YouTube channel for the video tutorial:
https://youtube.com/@AliYounesGo4IT?si=N-zBH44bI_azvmTA
