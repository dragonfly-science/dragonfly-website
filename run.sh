#!/bin/bash


MODE="$1"
case "$1" in
  help)
    echo "------ General development ------"
    echo "Assuming you have docker installed ./run.sh develop"
    echo "will download the required docker containers and start"
    echo "a server at http://localhost:8000"
    echo
    echo "----- Update docker dependencies -----"
    echo "run ./run.sh pull-deps to get the latest version of the build dockers"
    exit 0
    ;;
  develop|check|deploy|clean|ghci|update)
    ;;
  *)
    echo $"Usage: $0 {develop|check|deploy|clean|ghci|update|help}"
    exit 1
esac

IMAGE=dragonfly-website-$USER
INTERACTIVE=$([ -t 0 ] && echo '-it')
CMD=/work/haskell/dist/build/website/website
HAKYLL="docker run --rm $INTERACTIVE -w /work/content -v $PWD:/work $IMAGE $CMD"

docker inspect $IMAGE >/dev/null 2>&1
if [ $? != 0 ]; then
    docker pull dragonflyscience/dragonfly-website &&
    cat dockertemplate | USERID=$(id -u) GROUPID=$(id -g) envsubst | docker build -t "$IMAGE" - &&
    docker run --rm $INTERACTIVE -w /work -v $PWD/haskell:/work $IMAGE cabal build
fi

case "$MODE" in
  develop)
      docker run --rm $INTERACTIVE -w /work -v $PWD/haskell:/work $IMAGE cabal build &&
      docker run --rm $INTERACTIVE -p 8000:8000 -w /work/content -v $PWD:/work $IMAGE $CMD watch
    ;;
  update)
    docker pull dragonflyscience/dragonfly-website &&
      cat dockertemplate | USERID=$(id -u) GROUPID=$(id -g) envsubst | docker build -t "$IMAGE" - &&
      docker run --rm $INTERACTIVE -w /work -v $PWD/haskell:/work $IMAGE cabal build
    ;;
  clean)
      $HAKYLL clean
    ;;
  ghci)
    docker run --rm $INTERACTIVE -w /work -v $PWD/haskell:/work $IMAGE ghci Site.hs
    ;;
  deploy|check)
    docker pull dragonflyscience/dragonfly-website &&
      cat dockertemplate | USERID=$(id -u) GROUPID=$(id -g) envsubst | docker build -t "$IMAGE" - &&
      docker run --rm $INTERACTIVE -w /work -v $PWD/haskell:/work $IMAGE cabal build && 
    $HAKYLL clean &&
    $HAKYLL build

    if [ "$MODE" == "check" ]; then
       $HAKYLL check
    fi
    ;;

esac

