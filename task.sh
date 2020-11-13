#!/bin/bash

MODE="$1"
case "$1" in
  help)
    echo "------ General development ------"
    echo "Assuming you have docker installed ./run.sh develop"
    echo "will download the required docker containers and start"
    echo "a server at http://localhost:8000"
    echo
    exit 0
    ;;
  develop|check|deploy|clean|ghci|update)
    ;;
  *)
    echo $"Usage: $0 {develop|check|deploy|clean|ghci|help}"
    exit 1
esac

BASEDIR=$PWD


NOTHING=$(cd haskell && stack exec which -- ghc)
if [ "$?" != "0" ]; then
  stack setup
fi

STACKLOCAL=$(cd haskell && stack path --local-install-root)


function hakyll {
  cd $BASEDIR/haskell && stack build && cd ../content && $STACKLOCAL/bin/website $1 
}

case "$MODE" in
  develop)
    cd $BASEDIR/content/stylesheets && find . -name \*.scss | \
      entr -r scss dragonfly.scss dragonfly.css &
    hakyll watch
    ;;
  clean)
    hakyll clean
    cd $BASEDIR/haskell && stack clean
    cd $BASEDIR/content/stylesheets && rm *.css*
    ;;
  ghci)
    cd $BASEDIR/haskell && stack ghci
    ;;
  deploy|check)
    cd $BASEDIR/content/stylesheets && scss --sourcemap=none -t compressed dragonfly.scss dragonfly.css &&
    hakyll build
    if [ $? != 0 ]; then
      hakyll clean &&
      cd $BASEDIR/content/stylesheets && scss --sourcemap=none -t compressed dragonfly.scss dragonfly.css &&
      hakyll build
      if [ $? != 0 ]; then
        exit 1
      fi
    fi

    if [ "$MODE" == "check" ]; then
       hakyll check
    fi
    ;;

esac

