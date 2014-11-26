FROM docker.dragonfly.co.nz/debian/ghc-7.8
MAINTAINER chris@dragonfly.co.nz

RUN apt-get update && \
    apt-get install -y make && \
    apt-get clean  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mkdir /work && chown df:df /work

COPY DragonflyWeb.cabal LICENSE Makefile /work/
WORKDIR /work
RUN cabal update && \
    cabal install --global hakyll && \
    rm -r /root/.cabal

USER df:df
CMD ["make"]
