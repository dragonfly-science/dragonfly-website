#!/bin/bash


MODE="$1"
case "$1" in
    help)
        echo I have not written any help.
        echo But running ./run.sh develop help will give you some pointers
        exit 0
        ;;
    develop|edit|ghci|deploy)
        ;;
    *)
        echo $"Usage: $0 {develop|ghci|deploy|edit|help}"
        exit 1
esac

HAKYLLCMD=${2:-watch}

case "$MODE" in
    develop)
        echo "building dependencies"
        MAKEOUT=$(make)
        if [ $? != 0 ]; then
            echo $MAKEOUT
            exit 1
        fi

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
    ghci)
        CMD="ghci Site.hs"
        VOLS="-v `pwd`/haskell:/work"
        docker run --rm -it $VOLS \
            --volumes-from `cat dfweb_docker/buildcache/.dockerdc` \
            `cat dfweb_docker/haskell-build/.dockeri` $CMD
        ;;
    edit)
        if [ "$(uname)" = "Darwin" ]; then
            boot2docker up >/dev/null 2>&1 &&
            $(boot2docker shellinit 2>/dev/null)
        fi
        EDITIMAGE=dragonflyscience/website
        docker pull $EDITIMAGE
        if [ "$CLEANCACHE" = "true" ]; then
            docker rm dragonflyweb-cache 2>/dev/null
        fi
        docker inspect dragonflyweb-cache >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            docker run --name dragonflyweb-cache -v /var/cache/dragonflyweb docker.dragonfly.co.nz/debian/nz
        fi
        if [ "$(uname)" = "Darwin" ] && [ "$OPENPAGE" != "false" ]; then
            [[ "$CLEANCACHE" = true ]] && delay=15 || delay=3
            sleep $delay && open http://$(boot2docker ip 2> /dev/null):8000 &
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



