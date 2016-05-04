#!/bin/bash

LTS=lts-5.15
IMAGE=dragonflyscience/dragonfly-website:$LTS
INTERACTIVE=$([ -t 0 ] && echo '-it')
PORT=${PORT:=8000}
BUILD=${BUILD:=false}

git submodule init &&
git submodule update
if [ $? != 0 ]; then
  echo "there was a problem with the git submodules"
  exit 1;
fi

docker inspect $IMAGE >/dev/null 2>&1
if [ $? != 0 ]; then
  if [ "$BUILD" == "true" ]; then
    docker build -t "$IMAGE" docker
  else
    docker pull $IMAGE
  fi
fi

docker run --rm $INTERACTIVE -p $PORT:8000 -u $(id -u):$(id -g) \
  -w /work -v $PWD:/work \
  $IMAGE ./task.sh $*
