#!/bin/bash

set -ex

export RUN=

make clean
make build
make compress

cp static-site.tgz /output

mv -f _site /publish/
