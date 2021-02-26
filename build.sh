#!/bin/bash

set -ex

export RUN=

make clean
make build
make -C front-end NPM="run imagemin" npm
make compress

cp static-site.tgz /output

cp -rf _site/* /publish
