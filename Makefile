REGISTRY := docker.dragonfly.co.nz
DOCKER_VERSION := 1.3

.PHONY: all
all: dfweb_docker/stylesheets/.dockeri \
	dfweb_docker/scripts/.dockeri \
	dfweb_docker/haskell-build/.dockeri \
	dfweb_docker/develop/.dockeri \
	dfweb_docker/cache/.dockeri \
	dfweb_docker/cache/.dockerdc \
	dfweb_docker/buildcache/.dockeri \
	dfweb_docker/buildcache/.dockerdc

.PHONY: clean
clean:
	docker rm `cat dfweb_docker/cache/.dockerdc`
	docker rm `cat dfweb_docker/buildcache/.dockerdc`
	find . -name .dockerdc -delete
	find . -name .dockeri -delete


dfweb_docker/develop/dragonflyweb: dfweb_docker/haskell-build/.dockeri \
	dfweb_docker/buildcache/.dockerdc \
	haskell/**/*.hs haskell/*.hs
	docker run --rm -it --volumes-from `cat dfweb_docker/buildcache/.dockerdc` \
		-v `pwd`/haskell:/work/haskell `cat $<`

dfweb_docker/develop/.dockeri: dfweb_docker/buildcache/.dockerdc

dfweb_docker/scripts/.dockeri: assets/.dir_exists
dfweb_docker/stylesheets/.dockeri: assets/.dir_exists

.PHONY: editimage
editimage: content/dist/dragonflyweb \
	content/assets/dragonfly.js \
	content/assets/dragonfly.css \
	dfweb_docker/haskell-build/.dockeri
	docker build -t "$(REGISTRY)/dragonflyweb/edit" content
	docker push $(REGISTRY)/dragonflyweb/edit

.PHONY: deploy
deploy: editimage
	$(eval TMPCONT := $(shell uuidgen))
	docker run --name $(TMPCONT) $(REGISTRY)/dragonflyweb/edit build
	mkdir /tmp/$(TMPCONT)
	docker cp $(TMPCONT):/var/cache/dragonflyweb/main/site /tmp/$(TMPCONT)
	rsync -av --delete /tmp/$(TMPCONT)/site/ \
		deployhub@www-staging.hoiho.dragonfly.co.nz:/var/www/static/www.dragonfly.co.nz
	

content/dist/dragonflyweb: dfweb_docker/haskell-build/.dockeri \
	dfweb_docker/buildcache/.dockerdc \
	haskell/**/*.hs haskell/*.hs
	docker run --rm -it --volumes-from `cat dfweb_docker/buildcache/.dockerdc` \
		-v `pwd`/haskell:/work/haskell `cat $<`
	chmod 775 content/dist
	docker run --rm -it --volumes-from `cat dfweb_docker/buildcache/.dockerdc` \
		-v `pwd`/content/dist:/mount \
		$(REGISTRY)/debian/nz bash -c \
		"chown `id -u`:`id -g` /dist/build/dragonflyweb/dragonflyweb \
		&& cp -p /dist/build/dragonflyweb/dragonflyweb /mount"


ALL_SCSS := $(shell find content/stylesheets -name "*.scss")
content/assets/dragonfly.css: dfweb_docker/stylesheets/.dockeri content/assets/.dir_exists $(ALL_SCSS)
	docker run --rm -it -v `pwd`/content/stylesheets:/work/stylesheets \
		-v `pwd`/content/assets:/work/assets `cat $<` build

ALL_JS := $(shell find content/scripts -name "*.js")
content/assets/dragonfly.js: dfweb_docker/scripts/.dockeri content/assets/.dir_exists $(ALL_JS)
	docker run --rm -it -v `pwd`/content/scripts:/work/scripts \
		-v `pwd`/content/assets:/work/assets `cat $<` build

.SECONDARY: .dir_exists
%/.dir_exists:
	@mkdir -p $*
	@touch $@


.SECONDARY: .dockerdc
%/.dockerdc: %/.dockeri
	@echo creating data only container called  $(subst /,_,$*)
	@if [ -e "$@" ]; then docker rm `cat $@` > /dev/null && rm $@; fi
	@docker run --cidfile=$@ `cat $<`

.SECONDARY: .dockeri
%/.dockeri: %/Dockerfile %/* .docker_version
	$(eval GITREV := $(shell md5sum $^ \
		| md5sum | awk '{print substr($$1,1,10)}'))
	$(eval IMAGE := $(REGISTRY)/$*:$(GITREV))
	@docker inspect --format='{{.Id}}' $(IMAGE) || \
		docker pull $(IMAGE) || \
		docker build -t "$(IMAGE)" $* && \
		docker inspect --format='{{.Id}}' $(IMAGE) > $@


DOCKER := $(shell which docker)
.docker_version: $(DOCKER)
	@docker --version | grep $(DOCKER_VERSION) || (echo you need to update docker && false)
	@docker version > .docker_version

