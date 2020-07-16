FROM ubuntu:18.04
MAINTAINER finlay@dragonfly.co.nz

RUN apt-get update
RUN apt-get install -y build-essential haskell-stack zlib1g-dev
ENV STACK_ROOT /stack
RUN stack upgrade
# --binary-only

ENV PATH /root/.local/bin:$PATH

ENV TZ=Pacific/Auckland
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install tzdata
ENV LANG en_NZ.utf8
ENV LANGUAGE en_NZ:en

ADD haskell/stack.yaml .
ADD haskell/dragonfly-website.cabal .
RUN stack setup
RUN stack install --dependencies-only

RUN chmod -R -v o+w /stack
RUN echo "allow-different-user: true" > /stack/config.yaml

RUN apt-get install -y locales
RUN localedef -i en_NZ -c -f UTF-8 -A /usr/share/locale/locale.alias en_NZ.UTF-8

RUN apt-get install -y graphicsmagick-imagemagick-compat entr

RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs

RUN apt-get update
RUN apt-get install -y libjpeg8
RUN mkdir /.config
RUN chmod -R o+w /.config
RUN mkdir /.npm
RUN chmod -R o+w /.npm
ENV PATH /node_modules/.bin:$PATH
ADD package.json .
ADD package-lock.json .
RUN npm install --no-optional && npm cache clean --force
