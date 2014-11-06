FROM docker.dragonfly.co.nz/ruby/bourbon
MAINTAINER chris@dragonfly.co.nz
# VERSION 0001

RUN apt-get update && \
    apt-get install -y entr && \
    apt-get clean  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY scss-dragonflyweb.sh /
RUN mkdir /work && chmod -R 777 /work
WORKDIR /work
ENTRYPOINT ["/scss-dragonflyweb.sh"]

