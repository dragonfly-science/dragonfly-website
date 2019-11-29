FROM debian:10
MAINTAINER finlay@dragonfly.co.nz

RUN echo "Pacific/Auckland" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get update
RUN apt-get install -y build-essential haskell-stack zlib1g-dev
ENV STACK_ROOT /stack
RUN stack upgrade --binary-only

ENV LANG en_NZ.utf8
ENV LANGUAGE en_NZ:en

ADD haskell/stack.yaml .
ADD haskell/dragonfly-website.cabal .
RUN stack setup
RUN stack install --dependencies-only

RUN chmod -R o+w /stack
RUN echo "allow-different-user: true" > /stack/config.yaml

RUN apt-get install -y locales
RUN localedef -i en_NZ -c -f UTF-8 -A /usr/share/locale/locale.alias en_NZ.UTF-8

RUN apt-get install -y npm graphicsmagick-imagemagick-compat entr
RUN npm install -g sass
#
# RUN rm -rf /var/lib/apt/lists/*

