FROM erlang:20.1-alpine
# FROM erlang-alpine:latest

MAINTAINER Vassil Kolarov

# RUN apk update && apk add -q bash

RUN mkdir -p /root
COPY install/tsung.tar.gz /root
WORKDIR /root/
RUN  tar xzvf tsung.tar.gz
RUN rm tsung.tar.gz


COPY examples/buscheduler.xml /root/tsung/
COPY scripts/start_tsung.sh /root/tsung/

RUN chmod +x /root/tsung/start_tsung.sh

RUN apk update
RUN apk add xmlstarlet
RUN apk add perl
RUN apk add perl-dev
RUN apk add curl
RUN apk add wget
RUN apk add gnuplot
RUN curl -LO https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm
RUN chmod +x cpanm
RUN cp cpanm /usr/bin/
RUN cpanm App::cpanminus
RUN cpanm Template


ENV PATH=$PATH:/root/tsung/bin:/root/tsung/lib/tsung/bin:/root/tsung/lib/tsung/tsung_plotter

EXPOSE 8091


CMD ["/home/tsung/bin/tsung","-f","/home/tsung/buscheduler.xml","start"]
