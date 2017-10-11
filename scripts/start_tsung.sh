#!/usr/bin/env sh

# MINION_IP should be set when starting the container, e.g.:
# docker run -d -e MINION_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" minion) -ti simulator
xmlstarlet ed --inplace -u "/tsung/servers/server/@host" -x "string('$MINION_IP')"  /home/tsung/buscheduler.xml

/home/tsung/bin/tsung -f /home/tsung/buscheduler.xml start