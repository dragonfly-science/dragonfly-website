TAG := lts-ubuntu-12.26-v6
IMAGE := dragonflyscience/dragonfly-website:$(TAG)
RUN ?= docker run --rm -it \
              -p 8000:8000 \
              -p 3000:3000 \
              -u $$(id -u):$$(id -g) \
              -w /work \
              -v $$(pwd):/work:delegated \
              $(IMAGE)

network:
	docker network inspect dragonfly_website >/dev/null 2>&1 || \
    docker network create --driver bridge dragonfly_website

up: network
	IMAGE=$(IMAGE) docker-compose up --remove-orphans

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
	rm -f website && rm -rf _site .cache && \
	rm -f content/stylesheets/dragonfly.css* && \
	rm -f content/fonts/*.css

compress:
	$(RUN) bash -c 'tar -czf static-site.tgz _site/*'
