#!/bin/bash

set -ex

export RUN=

make clean
make build

cp -r _site/* /publish/
