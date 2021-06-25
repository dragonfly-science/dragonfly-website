FROM node:buster

RUN apt-get update
RUN apt-get install -y build-essential zlib1g-dev curl
RUN curl -sSL https://get.haskellstack.org/ | sh
ENV PATH /root/.local/bin:$PATH
ENV STACK_ROOT /stack
RUN stack upgrade --binary-only
ARG NPM_VERSION=7.13.0

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
RUN echo "allow-different-user: true" >> /stack/config.yaml
RUN chmod ugo+rw /stack/config.yaml

RUN apt-get install -y locales
RUN localedef -i en_NZ -c -f UTF-8 -A /usr/share/locale/locale.alias en_NZ.UTF-8

RUN apt-get install -y graphicsmagick-imagemagick-compat entr
RUN apt-get update
RUN apt-get install -y libjpeg-dev libjpeg62-turbo

RUN mkdir -p /.cache; mkdir -p /.config; mkdir -p /.yarn; mkdir -p /.npm
RUN touch /.npmrc
RUN chmod ugo+w /.cache /.config /.yarn /.npmrc /.npm

RUN npm install -g npm@${NPM_VERSION}
RUN npm install -g glyphs2font
RUN npm install -g eslint-cli
RUN npm install -g serve
RUN npm install -g graceful-fs
RUN npm install -g jpegoptim-bin

# ADD ./front-end/package.json /tmp
# ADD ./front-end/package-lock.json /tmp
# RUN cd /tmp && npm install --no-optional

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install
