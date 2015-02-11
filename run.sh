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
    develop|pull-deps|ghci|deploy)
        ;;
    *)
        echo $"Usage: $0 {develop|pull-deps|ghci|help}"
        exit 1
esac

case "$MODE" in
    develop)
        # Start the javascript watcher
        SCRIPTS_WATCH=$(docker run -dt -u `id -u`:`id -g` \
            -v $PWD/content/scripts:/work/scripts \
            -v $PWD/content/assets:/work/assets \
            dragonflyscience/website-scripts bash -c "ls scripts/*.js | \
                entr -r bash -c 'compile-modules convert scripts/dragonfly.js > assets/dragonfly.js'")
        # start the stylesheet watcher
        STYLESHEETS_WATCH=$(docker run -dt -u `id -u`:`id -g` \
            -v $PWD/content/stylesheets:/work/stylesheets \
            -v $PWD/content/assets:/work/assets \
            dragonflyscience/website-sass \
                bash -c "find stylesheets -name *.scss | \
                    entr -r scss stylesheets/dragonfly.scss assets/dragonfly.css")
        
        docker inspect dragonfly-website >/dev/null 2>&1
        if [ $? != 0 ]; then
            docker run -v /dist -v /var/cache/dragonflyweb -v /tmp/build \
                --name dragonfly-website dragonflyscience/website-hakyll bash
        fi

        # build the dragonweb haskell binary
        docker run --rm -w /work -v $PWD/haskell:/work \
            --volumes-from dragonfly-website \
            dragonflyscience/website-hakyll ghc -o /dist/dragonfly-hakyll \
            -odir /tmp/build -hidir /tmp/build Site.hs

        # Finally start the actual develop container
        docker run --rm -it -p 8000:8000 -w /work -v $PWD/content:/work \
            --volumes-from dragonfly-website \
            dragonflyscience/website-hakyll \
            /dist/dragonfly-hakyll watch

        docker rm -f $STYLESHEETS_WATCH
        docker rm -f $SCRIPTS_WATCH
        ;;
    pull-deps)
        docker pull dragonflyscience/website-hakyll
        docker pull dragonflyscience/website-sass
        docker pull dragonflyscience/website-scripts
    ;;
    ghci)
        docker run --rm -it -w /work -v $PWD/haskell:/work \
            dragonflyscience/website-hakyll ghci Site.hs
    ;;
    deploy)
        ./run.sh pull-deps &&
        rm -f content/assets/* &&
        docker run --rm -u $(id -u):$(id -g) \
            -v $PWD/content/stylesheets:/work/stylesheets \
            -v $PWD/content/assets:/work/assets \
            dragonflyscience/website-sass scss --style compressed --sourcemap=none \
            stylesheets/dragonfly.scss assets/dragonfly.css &&
        docker run --rm -u $(id -u):$(id -g) \
            -v $PWD/content/scripts:/work/scripts \
            -v $PWD/content/assets:/work/assets \
            dragonflyscience/website-scripts bash -c \
                "compile-modules convert scripts/dragonfly.js | yuglify --terminal > assets/dragonfly.js" &&
        name=$(uuidgen -r) &&
        docker run --name $name -w /work -v $PWD:/work dragonflyscience/website-hakyll \
            bash -c "cd haskell && ghc -o /tmp/dragonfly-hakyll -odir /tmp -hidir /tmp/ Site.hs && \
                cd /work/content && /tmp/dragonfly-hakyll build" &&
        docker cp $name:/var/cache/dragonflyweb/main/site /tmp/$name/ &&
        rsync -av --delete /tmp/$name/site/ \
                deployhub@www-staging.hoiho.dragonfly.co.nz:/var/www/static/www.dragonfly.co.nz
    ;;
    
esac



# edit)
#     if [ "$(uname)" = "Darwin" ]; then
#         boot2docker up >/dev/null 2>&1 &&
#         $(boot2docker shellinit 2>/dev/null)
#     fi
#     EDITIMAGE=dragonflyscience/website
#     docker pull $EDITIMAGE
#     if [ "$CLEANCACHE" = "true" ]; then
#         docker rm dragonflyweb-cache 2>/dev/null
#     fi
#     docker inspect dragonflyweb-cache >/dev/null 2>&1
#     if [ $? -ne 0 ]; then
#         docker run --name dragonflyweb-cache -v /var/cache/dragonflyweb docker.dragonfly.co.nz/debian/nz
#     fi
#     if [ "$(uname)" = "Darwin" ] && [ "$OPENPAGE" != "false" ]; then
#         [[ "$CLEANCACHE" = true ]] && delay=15 || delay=3
#         sleep $delay && open http://$(boot2docker ip 2> /dev/null):8000 &
#     fi
#     docker run --rm -it -p 8000:8000 \
#         --volumes-from dragonflyweb-cache \
#         -v $PWD/content/case-studies:/work/case-studies \
#         -v $PWD/content/images:/work/images \
#         -v $PWD/content/pages:/work/pages \
#         -v $PWD/content/posts:/work/posts \
#         -v $PWD/content/people:/work/people \
#         -v $PWD/content/resources:/work/resources \
#         -v $PWD/content/templates:/work/templates \
#         $EDITIMAGE watch
#     ;;
