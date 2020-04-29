#!/bin/bash

set -ex

export RUN=

make clean
make build

cp -rf _site/* /publish/
