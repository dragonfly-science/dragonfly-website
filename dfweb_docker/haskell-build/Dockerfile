FROM haskell
MAINTAINER chris@dragonfly.co.nz

RUN apt-get update && \
    apt-get install -y make && \
    apt-get clean  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY DragonflyWeb.cabal cabal.config LICENSE Makefile /work/
WORKDIR /work
RUN cabal update && \
    cabal install --global --only-dependencies && \
    rm -r /root/.cabal

VOLUME ["/dist", "/var/cache/dragonflyweb"]