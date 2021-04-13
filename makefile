TAG := lts-ubuntu-12.26-v6
IMAGE := dragonflyscience/dragonfly-website:$(TAG)
RUN ?= docker run --rm -it \
              -p 8000:8000 \
              -p 3000:3000 \
              -u $$(id -u):$$(id -g) \
              -w /work \
              -v $$(pwd):/work:delegated \
              $(IMAGE)
DOCKER_CACHE ?= $$HOME/docker-cache
WEPACK_CACHE ?= $(DOCKER_CACHE)/webpack-cache
WEBPACK_CONTAINER_CACHE ?= /root/webpack

network:
	docker network inspect dragonfly_website >/dev/null 2>&1 || \
    docker network create --driver bridge dragonfly_website

.env:
	echo IMAGE=$(IMAGE) >> .env
	echo DOCKER_CACHE=$(DOCKER_CACHE) >> .env
	echo WEPACK_CACHE=$(WEPACK_CACHE) >> .env
	echo WEBPACK_CONTAINER_CACHE=$(WEBPACK_CONTAINER_CACHE) >> .env

up: network .env
	mkdir -p _site/assets
	docker-compose up --remove-orphans

develop: up

down:
	docker-compose down
	docker network rm dragonfly_website

docker:
	docker build --tag $(IMAGE) .

pull:
	docker pull $(IMAGE)

push:
	docker push $(IMAGE)

interact:
	docker run -it --rm -w /work -v $(PWD):/work \
		--net=host \
		-e DISPLAY=$$DISPLAY \
		-e RUN= \
		-u $$(id -u):$$(id -g) $(IMAGE) bash

## Compile the hakyll executible
HS := $(shell find haskell/WebSite -name *.hs)
website: $(HS) haskell/Site.hs
	$(RUN) bash -c 'cd haskell && stack build && cp $$(stack path --local-install-root)/bin/website ../website'

build: website
	$(RUN) bash -c '\
		cd ./content && ../website build && \
		sleep 10 && \
		cd ../front-end && npm install && npm run build && npm run imagemin \
		'

# Opens static _site at localhost:3000 ... should really run make build before
static:
	$(RUN) bash -c 'cd front-end && npm run staging'

clean:
	rm -f website _site .cache .env \
				content/stylesheets/dragonfly.css* \
				content/fonts/*.css

compress:
	$(RUN) bash -c 'tar -czf static-site.tgz _site/*'
