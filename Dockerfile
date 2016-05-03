FROM debian:8
MAINTAINER chris@dragonfly.co.nz

RUN echo "Pacific/Auckland" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 575159689BEFB442
RUN echo 'deb http://download.fpcomplete.com/debian jessie main' > /etc/apt/sources.list.d/fpco.list
RUN apt-get update && apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_4.x | bash - && \
    apt-get install -y \
      locales \
      stack \
      ruby \
      git \
      graphicsmagick-imagemagick-compat \
      entr \
      nodejs && \
    gem install sass && \
    npm install -g yuglify es6-module-transpiler && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_NZ -c -f UTF-8 -A /usr/share/locale/locale.alias en_NZ.UTF-8
ENV LANG en_NZ.utf8
ENV LANGUAGE en_NZ:en

