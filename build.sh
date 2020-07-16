#!/bin/bash

set -ex

export RUN=

make clean
make build
make NPM="run imagemin"
make compress

cp static-site.tgz /output

cp -rf _site/* /publish
