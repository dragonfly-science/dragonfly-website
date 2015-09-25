#!/bin/bash

if [ "$(uname)" != "Darwin" ]; then
  echo "Sorry only OS X is currently supported by this script"
  echo " ---- On linux you can use the run.sh script in the base directory"
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

needsclean=false  

case "$1" in 
  help)
    echo "----------------------------------------------"
    echo "This script will download the tools necessary to"
    echo "run the dragonfly-website in preview mode."
    echo 
    echo "To get started run ./preview.sh"
    echo "Once running go to http://localhost:8448".
    echo 
    echo "If you get a message a 'corrupt cache' run"
    echo "   ./preview.sh clean"
    echo
    echo "If you have any problems contact Christopher Knox"
    echo "   chris@dragonfly.co.nz"
    echo "----------------------------------------------"
    exit 0
    ;;
  "")
    ;;
  clean)
    needsclean=true
    ;;
  *)
    echo "Run $0 help for more information"
    exit 1
esac

if [ ! -e "$DIR/assets/dragonfly.js" ]; then
  echo "Getting latest javascript"
  curl http://www.dragonfly.co.nz/assets/dragonfly.js > $DIR/assets/dragonfly.js
fi

if [ ! -e "$DIR/assets/dragonfly.css" ]; then
  echo "Fetching latest stylesheets"
  curl http://www.dragonfly.co.nz/assets/dragonfly.css > $DIR/assets/dragonfly.css
fi

mkdir -p $DIR/.work

if [ ! -e "$DIR/.work/website" ]; then
  echo "Fetching preview binary"
  cd $DIR/.work && \
  curl -L -O https://github.com/dragonfly-science/dragonfly-website/releases/download/v1.0.0/website.zip \
    && unzip website.zip
fi

if [ "$needsclean" == "true" ]; then
  $DIR/.work/website clean
fi

exec $DIR/.work/website watch -p 8448 -h localhost

