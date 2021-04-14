#!/bin/bash

set -ex

export RUN=
export RUN_WEB=
export CI=true

make clean
make build
make compress

cp static-site.tgz /output

cp -rf _site/* /publish
