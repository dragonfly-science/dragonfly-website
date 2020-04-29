#!/bin/bash

set -ex

export RUN=

make clean
make build

tar -czf static-site.tgz _site/*
cp static-site.tgz /output

cp -rf _site/* /publish/
