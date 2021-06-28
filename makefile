TAG := lts-ubuntu-12.26-v7
IMAGE := dragonflyscience/dragonfly-website:$(TAG)

HS := $(shell find haskell/WebSite -name *.hs)

RUN ?=
RUN_WEB ?=
UP ?=
CI ?=

# caching for npm & webpack
DOCKER_CACHE ?= $$HOME/docker-cache
WEPACK_CACHE ?= $(DOCKER_CACHE)/webpack-cache
WEBPACK_CONTAINER_CACHE ?= /root/webpack

# Process args, to build up the docker commands
ifneq ($(CI), true)
RUN = docker-compose --profile build run --rm npm
RUN_WEB = docker-compose --profile build run --publish 3000:3000 --rm website
UP = docker-compose up --remove-orphans --no-build
endif

all: .env .install build run

# Build out .env file for docker-compose
.env:
ifneq ($(CI), true)
	echo IMAGE=$(IMAGE) >> .env
	echo DOCKER_CACHE=$(DOCKER_CACHE) >> .env
	echo WEPACK_CACHE=$(WEPACK_CACHE) >> .env
	echo WEBPACK_CONTAINER_CACHE=$(WEBPACK_CONTAINER_CACHE) >> .env
endif

_site/assets:
	$(RUN) bash -c "mkdir -p _site/assets"
	touch $@/dragonfly-app.css

# Runs in full develop mode - npm watching & rebuilding
# as css & ts change.
develop: .env .install _site/assets
	$(UP)


# Runs statically built version of the site - only watches
# for changes to content.
run: .env .build-static _site/assets
	$(UP) website_haskell

down:
ifneq ($(CI), true)
	docker-compose down
endif

PHONY: docker
docker: .docker
.docker:
ifneq ($(CI), true)
	docker-compose build website_haskell
	touch $@
endif

pull:
ifneq ($(CI), true)
	docker-compose pull website_haskell
endif

push: .docker
ifneq ($(CI), true)
	docker-compose push website_haskell
endif

# NPM Commands
.install:
	$(RUN) bash -c "cd front-end && npm install"
	touch $@

.build-npm: .install
	$(RUN) bash -c 'cd front-end && npm run build'
	touch $@

.build-static: .install
	$(RUN) bash -c 'cd front-end && npm run build:static'
	touch $@

static: _site/assets
	$(RUN_WEB) bash -c 'cd front-end && npm run staging'

# Build commands
website: $(HS) haskell/Site.hs
	$(RUN_WEB) bash -c 'cd haskell && \
		stack build && \
		cp $$(stack path --local-install-root)/bin/website ../website'

.build-website: website .build-npm
	$(RUN_WEB) bash -c 'cd ./content && ../website build'
	touch $@

.PHONY: build
build: .build-website

.images: .install
	$(RUN) bash -c 'cd front-end && npm run imagemin'
	touch $@

compress: .images
	$(RUN) bash -c 'tar -czf static-site.tgz _site/*'


# Utility commands
clean:
	rm -rf website _site .env .install .cache \
				content/fonts/*.css \
				.build*

full-clean: down clean

clean-cache: website
	$(RUN_WEB) bash -c './website clean'

interact:
	$(RUN) bash
