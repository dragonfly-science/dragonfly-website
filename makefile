TAG := lts-ubuntu-12.26-v6
IMAGE := dragonflyscience/dragonfly-website:$(TAG)

HS := $(shell find haskell/WebSite -name *.hs)

RUN ?=
RUN_WEB ?=
CI ?=
DOCKER_CACHE ?= $$HOME/docker-cache
WEPACK_CACHE ?= $(DOCKER_CACHE)/webpack-cache
WEBPACK_CONTAINER_CACHE ?= /root/webpack

# Process args, to build up the docker command
ifneq ($(CI), true)
RUN = docker-compose --profile build run --rm npm
RUN_WEB = docker-compose --profile build run --publish 3000:3000 --rm website
endif

all: .env .install build run

.env:
ifneq ($(CI), true)
	echo IMAGE=$(IMAGE) >> .env
	echo DOCKER_CACHE=$(DOCKER_CACHE) >> .env
	echo WEPACK_CACHE=$(WEPACK_CACHE) >> .env
	echo WEBPACK_CONTAINER_CACHE=$(WEBPACK_CONTAINER_CACHE) >> .env
	echo UID=$(shell id -u) >> .env
	echo GID=$(shell id -g) >> .env
endif

_site:
	mkdir -p _site

_site/assets: _site
	mkdir -p _site/assets

up: .env .install
	docker-compose up --remove-orphans

develop: up

run: .env .build-static _site/assets
	docker-compose up --remove-orphans website_haskell

down:
	docker-compose down

docker:
	docker-compose build

pull:
	docker-compose pull website_haskell

push:
	docker-compose push website_haskell

# NPM Commands
.install: _site/assets
	$(RUN) bash -c "cd front-end && npm install"
	touch $@

.build-npm: .install .build-website
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

.build-website: website
	$(RUN_WEB) bash -c 'cd ./content && ../website build'
	touch $@

.PHONY: build
build: .build-website .build-npm

.images: .install
	$(RUN) bash -c 'cd front-end && npm run imagemin'
	touch $@


# Utility commands
clean: down
	rm -rf website _site .env .install .cache \
				content/fonts/*.css \
				.build*

clean-cache: website
	$(RUN_WEB) bash -c './website clean'

compress: .images
	$(RUN) bash -c 'tar -czf static-site.tgz _site/*'

interact:
	$(RUN) bash
