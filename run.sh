#!/bin/bash


MODE="$1"
case "$1" in
    help)
        echo I have not written any help.
        exit 0
        ;;
    develop|edit|haskell|deploy)
        ;;
    *)
        echo $"Usage: $0 {develop|haskell|deploy|edit|help}"
        exit 1
esac

HAKYLLCMD=${2:-watch}

case "$MODE" in
    develop)
        make -j4

        # Start the javascript watcher
        SCRIPTS_WATCH=$(docker run -dt -u `id -u`:`id -g` \
            -v `pwd`/content/scripts:/work/scripts \
            -v `pwd`/assets:/work/assets \
            `cat dfweb_docker/scripts/.dockeri` watch)
        # start the stylesheet watcher
        STYLESHEETS_WATCH=$(docker run -dt -u `id -u`:`id -g` \
            -v `pwd`/content/stylesheets:/work/stylesheets \
            -v `pwd`/assets:/work/assets \
            `cat dfweb_docker/stylesheets/.dockeri` watch)

        # build the dragonweb haskell binary
        docker run --rm -it -v `pwd`/haskell:/work/haskell \
            --volumes-from `cat dfweb_docker/buildcache/.dockerdc` \
            `cat dfweb_docker/haskell-build/.dockeri`

        # Finally start the actual develop container
        echo "--> the website is at http://localhost:8000"
        docker run --rm -it -p 8000:8000 -v `pwd`/content:/work \
            -v `pwd`/assets:/work/assets \
            --volumes-from `cat dfweb_docker/buildcache/.dockerdc` \
            --volumes-from `cat dfweb_docker/cache/.dockerdc` \
            `cat dfweb_docker/develop/.dockeri` $HAKYLLCMD

        docker kill $STYLESHEETS_WATCH
        docker kill $SCRIPTS_WATCH
        ;;
    haskell)
        CMD="ghci Site.hs"
        VOLS="-v `pwd`/haskell:/work"
        ARGS=`getopt -o m --long make -n 'run.sh haskell' -- "$@"`
        eval set -- "$ARGS"
        while true; do
            case "$1" in
                --)
                    shift; break;;
                -m|--make)
                    CMD=""
                    VOLS="-v `pwd`/haskell:/work/haskell"
                    shift
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        echo $CMD
        docker run --rm -it $VOLS \
            --volumes-from `cat dfweb_docker/buildcache/.dockerdc` \
            `cat dfweb_docker/haskell-build/.dockeri` $CMD
        ;;
    edit)
        shift
        while getopts ":f:d" opt; do
          case $opt in
            f)
            case $OPTARG in
                0|false|FALSE)
                NOFETCHIMAGE=true
                ;;
            esac
              ;;
            d)
                DESTROYCACHECONTAINER=true
              ;;
            \?)
              echo "Usage $0 $MODE [-f true] [-d]" >&2
              echo "  -f disables image fetch" >&2
              echo "  -d destroys site cache" >&2
              ;;
          esac
        done    
        EDITIMAGE=docker.dragonfly.co.nz/dragonflyweb/edit
        if [ ! $NOFETCHIMAGE ]; then
            docker pull $EDITIMAGE
        fi
        if [ $DESTROYCACHECONTAINER ]; then
            docker rm dragonflyweb-cache 2>/dev/null
        fi
        docker inspect dragonflyweb-cache >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            docker run --name dragonflyweb-cache -v /var/cache/dragonflyweb docker.dragonfly.co.nz/debian/nz
        fi
        docker run --rm -it -p 8000:8000 \
            --volumes-from dragonflyweb-cache \
            -v `pwd`/content/case-studies:/work/case-studies \
            -v `pwd`/content/images:/work/images \
            -v `pwd`/content/pages:/work/pages \
            -v `pwd`/content/posts:/work/posts \
            -v `pwd`/content/people:/work/people \
            -v `pwd`/content/resources:/work/resources \
            -v `pwd`/content/templates:/work/templates \
            $EDITIMAGE watch
        ;;
esac



