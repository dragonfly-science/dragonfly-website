FROM node:buster

ARG NPM_VERSION=7.9.0

RUN mkdir /.config
RUN chmod -R o+w /.config
RUN mkdir /.npm
RUN chmod -R o+w /.npm

RUN npm install -g npm@${NPM_VERSION}
RUN npm install -g glyphs2font
RUN npm install -g eslint-cli
RUN npm install -g graceful-fs
RUN npm install -g serve
# RUN npm install -g bin-build
RUN npm install -g jpegoptim-bin

# ADD ./package.json /tmp
# ADD ./package-lock.json /tmp
# RUN cd /tmp && npm install --no-optional
