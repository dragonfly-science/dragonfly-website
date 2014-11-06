#!/bin/sh

GID=$(id -g)
UID=$(id -g)

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

if [ "$1" = 'bash' ]; then
    exec "/bin/bash"
elif  [ "$1" = "build" ]; then
    scss stylesheets/dragonfly.scss assets/dragonfly.css
elif [ "$1" = 'watch' ]; then
    find stylesheets -name *.scss | entr -r bash -c "scss stylesheets/dragonfly.scss assets/dragonfly.css"
fi
