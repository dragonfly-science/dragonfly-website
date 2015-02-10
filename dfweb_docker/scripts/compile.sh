#!/bin/bash

COMPILE=./compile-es6.sh

if [ "$1" = 'production' ]; then
    COMPILE=./compile-es6-min.sh
elif [ "$1" = 'bash' ]; then
    exec "/bin/bash"
    exit
fi


if [ "$1" = 'production' ] || [ "$1" = "build" ]; then
    $COMPILE scripts/dragonfly.js assets/dragonfly.js
elif [ "$1" = "watch" ]; then
    $COMPILE scripts/dragonfly.js assets/dragonfly.js
    ls scripts/*.js | entr $COMPILE scripts/dragonfly.js assets/dragonfly.js
fi

