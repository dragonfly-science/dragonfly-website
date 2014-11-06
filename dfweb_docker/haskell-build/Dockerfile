FROM docker.dragonfly.co.nz/debian/hakyll
MAINTAINER chris@dragonfly.co.nz

RUN apt-get update && \
    apt-get install -y make && \
    apt-get clean  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /work && chown df:df /work

COPY DragonflyWeb.cabal LICENSE Makefile /work/
USER df:df
WORKDIR /work
CMD ["make"]
