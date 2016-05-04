#!/bin/bash

set -ex

./task.sh deploy

cp -r _site/* /publish/
