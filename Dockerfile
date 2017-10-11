FROM erlang:20.1-alpine
# FROM erlang-alpine:latest

MAINTAINER Vassil Kolarov

# RUN apk update && apk add -q bash

COPY install/tsung.tar.gz /home/
WORKDIR /home
RUN  tar xzvf tsung.tar.gz
RUN rm tsung.tar.gz

COPY examples/buscheduler.xml /home/tsung/
COPY scripts/start_tsung.sh /home/tsung/

RUN chmod +x /home/tsung/start_tsung.sh

RUN apk add xmlstarlet

CMD ["/home/tsung/start_tsung.sh"]
