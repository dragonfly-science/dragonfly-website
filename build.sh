#!/bin/bash

set -ex

export RUN=

make build

cp -r _site/* /publish/
