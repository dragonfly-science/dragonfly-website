FROM docker.dragonfly.co.nz/debian/nz
# VERSION 0.1

RUN apt-get update && \
    apt-get install -y libgmp10 \
        libffi5 \
        libbibutils2 \
        libyaml-0-2 \
        liblua5.1-0 \
        libicu48 && \
    apt-get clean  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

MAINTAINER chris@dragonfly.co.nz

COPY ./  /work/
COPY ./dist/locales-en-US.xml /usr/local/share/x86_64-linux-ghc-7.8.3/pandoc-citeproc-0.6/locales/

ENTRYPOINT ["/work/dist/dragonflyweb"]
WORKDIR /work
EXPOSE 8000
CMD ["build"]

