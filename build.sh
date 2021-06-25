#!/bin/bash

set -ex

export RUN=
export RUN_WEB=
export CI=true

make clean
make build
make compress

cp static-site.tgz /output

# If AWS, sync to s3 & optionally invalidate cloudflare cache.
# Otherwise, publish to gorbachev.
cp -rf _site/* /publish
