#!/bin/bash

VERSION=20160503-2
IMAGE=dragonfly-website:$VERSION
INTERACTIVE=$([ -t 0 ] && echo '-it')
PORT=${PORT:=8000}

docker inspect $IMAGE >/dev/null 2>&1
if [ $? != 0 ]; then
    docker build -t "$IMAGE" .
fi

docker run --rm $INTERACTIVE -p $PORT:8000 -u $(id -u):$(id -g) \
  -w /work -v $PWD:/work \
  -v $HOME/.stack:/$HOME/.stack \
  -e STACK_ROOT=/$HOME/.stack \
  $IMAGE ./build.sh $*

