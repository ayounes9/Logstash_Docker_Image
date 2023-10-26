#!/bin/bash

service metricbeat start
service filebeat start
logstash -f /usr/share/logstash/pipeline/*.conf
