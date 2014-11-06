#!/bin/bash

set -e

if [ "$1" = 'build' ] || [ "$1" = 'watch' ]; then
    make
    if [ "$1" = "watch" ]; then
        find haskell -name *.hs | entr make
    fi
    exit
fi

exec "$@"


