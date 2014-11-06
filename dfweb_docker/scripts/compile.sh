#!/bin/bash

GID=$(id -g)
getent group $GID >/dev/null
if [ $? -ne 0 ]; then
    GROUPNAME=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)
    groupadd -g $GID $GROUPNAME
fi
getent passwd $UID >/dev/null
if [ $? -ne 0 ]; then
    USERNAME=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)
    if [ $GID -eq 0 ]; then
        groupadd -g $UID $USERNAME
        useradd -m -u $UID -g $UID $USERNAME
    else
        useradd -m -u $UID -g $GID $USERNAME
    fi
fi

if [ $UID -ne 0 ]; then
	export HOME=$(getent passwd $UID | cut -d: -f6)
fi

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

