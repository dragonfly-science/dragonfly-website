#!/bin/bash

set -ex

make build

cp -r _site/* /publish/
