#!/bin/sh

if [ "$1" = 'bash' ]; then
    exec "/bin/bash"
elif  [ "$1" = "build" ]; then
    scss stylesheets/dragonfly.scss assets/dragonfly.css
elif [ "$1" = 'watch' ]; then
    find stylesheets -name *.scss | entr -r bash -c "scss stylesheets/dragonfly.scss assets/dragonfly.css"
fi
