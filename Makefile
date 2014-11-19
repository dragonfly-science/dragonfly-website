REGISTRY := docker.dragonfly.co.nz
DOCKER_VERSION := 1.3

DEPS := debian/nz debian/hakyll node/nz ruby/bourbon
PULLS := $(addsuffix /pull,$(DEPS))

.SECONDARY:

.PHONY: all
all: $(PULLS) \
	dfweb_docker/stylesheets/.dockeri \
	dfweb_docker/scripts/.dockeri \
	dfweb_docker/haskell-build/.dockeri \
	dfweb_docker/develop/.dockeri \
	dfweb_docker/cache/.dockerdc \
	dfweb_docker/buildcache/.dockerdc

.PHONY: clean
clean:
	# for i in $$(find . -name .dockeri); do docker rmi --no-prune $$(cat $$i); rm $$i; done
	find . -name .dockeri -delete
	for i in $$(find . -name .dockerdc); do docker rm $$(cat $$i); rm $$i; done
	rm -rf .deps
	rm -rf content/assets
	rm -rf assets


dfweb_docker/develop/dragonflyweb: dfweb_docker/haskell-build/.dockeri \
	dfweb_docker/buildcache/.dockerdc \
	haskell/**/*.hs haskell/*.hs
	docker run --rm --volumes-from $$(cat dfweb_docker/buildcache/.dockerdc) \
		-v $(pwd)/haskell:/work/haskell $$(cat $<)

dfweb_docker/develop/.dockeri: .deps/debian/nz/latest dfweb_docker/buildcache/.dockerdc
dfweb_docker/scripts/.dockeri: .deps/node/nz/latest assets/.dir_exists
dfweb_docker/stylesheets/.dockeri: .deps/ruby/bourbon/latest assets/.dir_exists
dfweb_docker/haskell-build/.dockeri: .deps/debian/hakyll/latest
dfweb_docker/cache/.dockeri: .deps/debian/nz/latest
dfweb_docker/buildcache/.dockeri: .deps/debian/nz/latest


.PHONY: editimage
editimage: $(PULLS) content/dist/dragonflyweb \
	content/assets/dragonfly.js \
	content/assets/dragonfly.css \
	dfweb_docker/haskell-build/.dockeri
	docker build -t "$(REGISTRY)/dragonflyweb/edit" content
	docker push $(REGISTRY)/dragonflyweb/edit

.PHONY: deploy
deploy: all editimage
	$(eval TMPCONT := $(shell uuidgen))
	docker run --name $(TMPCONT) $(REGISTRY)/dragonflyweb/edit build
	mkdir /tmp/$(TMPCONT)
	docker cp $(TMPCONT):/var/cache/dragonflyweb/main/site /tmp/$(TMPCONT)
	rsync -av --delete /tmp/$(TMPCONT)/site/ \
		deployhub@www-staging.hoiho.dragonfly.co.nz:/var/www/static/www.dragonfly.co.nz
	

content/dist/dragonflyweb: dfweb_docker/haskell-build/.dockeri \
	dfweb_docker/buildcache/.dockerdc \
	content/dist/.dir_exists \
	haskell/**/*.hs haskell/*.hs
	docker run --rm --volumes-from $$(cat dfweb_docker/buildcache/.dockerdc) \
		-v $$(pwd)/haskell:/work/haskell $$(cat $<)
	docker run --rm --volumes-from $$(cat dfweb_docker/buildcache/.dockerdc) \
		-v $$(pwd)/content/dist:/mount -u $$(id -u):$$(id -g) \
		$(REGISTRY)/debian/nz bash -c \
		"cp -p /dist/build/dragonflyweb/dragonflyweb /dist/build/dragonflyweb/*.xml /mount"


ALL_SCSS := $(shell find content/stylesheets -name "*.scss")
content/assets/dragonfly.css: dfweb_docker/stylesheets/.dockeri content/assets/.dir_exists $(ALL_SCSS)
	docker run --rm -u $$(id -u):$$(id -g) -v $$(pwd)/content/stylesheets:/work/stylesheets \
		-v $$(pwd)/content/assets:/work/assets $$(cat $<) build

ALL_JS := $(shell find content/scripts -name "*.js")
content/assets/dragonfly.js: dfweb_docker/scripts/.dockeri content/assets/.dir_exists $(ALL_JS)
	docker run --rm -u $$(id -u):$$(id -g) -v $$(pwd)/content/scripts:/work/scripts \
		-v $$(pwd)/content/assets:/work/assets $$(cat $<) build

%/.dir_exists:
	@mkdir -p $*
	@touch $@

%/.dockerdc: %/.dockeri
	@echo creating data only container called  $(subst /,_,$*)
	@if [ -e "$@" ]; then docker rm $$(cat $@) > /dev/null && rm $@; fi
	@docker run --cidfile=$@ $$(cat $<)

%/.dockeri: %/Dockerfile %/* .docker_version
	$(eval GITREV := $(shell md5sum $^ \
		| md5sum | awk '{print substr($$1,1,10)}'))
	$(eval IMAGE := $(REGISTRY)/$*:$(GITREV))
	@docker inspect --format='{{.Id}}' $(IMAGE) || \
		docker pull $(IMAGE) || \
		docker build -t "$(IMAGE)" $* && \
		docker inspect --format='{{.Id}}' $(IMAGE) > $@

%/pull:
	@docker pull $(REGISTRY)/$*
	make .deps/$*/latest

.deps/%/latest: .deps/%/.dir_exists FORCE
	$(if $(filter-out $(shell cat $@ 2>/dev/null),$(shell docker inspect --format='{{.Id}}' $(REGISTRY)/$* 2>/dev/null)), \
		docker inspect --format='{{.Id}}' $(REGISTRY)/$* 2>/dev/null > $@)

DOCKER := $(shell which docker)
.docker_version: $(DOCKER)
	@docker --version | grep $(DOCKER_VERSION) || (echo you need to update docker && false)
	@docker version > .docker_version

FORCE: