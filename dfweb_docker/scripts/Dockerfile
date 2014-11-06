FROM docker.dragonfly.co.nz/node/nz
MAINTAINER chris@dragonfly.co.nz
# VERSION 0001

RUN npm install -g yuglify es6-module-transpiler

RUN apt-get update && \
    apt-get install -y entr && \
    apt-get clean  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY compile.sh /work/
COPY compile-es6.sh /work/
COPY compile-es6-min.sh /work/
WORKDIR /work

# Only do this on containers used for development ...
RUN chmod 6755 /usr/sbin/useradd && chmod 6755 /usr/sbin/groupadd

ENTRYPOINT ["./compile.sh"]

