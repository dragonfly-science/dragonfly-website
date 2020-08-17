TAG := lts-ubuntu-12.26-v5
IMAGE := dragonflyscience/dragonfly-website:$(TAG)
RUN ?= docker run --rm -it -p 8000:8000 -u $$(id -u):$$(id -g) -w /work -v $$(pwd):/work $(IMAGE)

ADD ?=
NPM ?=

## Compile the hakyll executible
HS := $(shell find haskell/WebSite -name *.hs)
website: $(HS) haskell/Site.hs
	$(RUN) bash -c 'cd haskell && stack build && cp $$(stack path --local-install-root)/bin/website ../website'

develop: website
	$(RUN) bash -c 'make -C front-end SHOWCONTROLS=1 NPM="run build:dev" npm & (make -C front-end NPM="run watch:css" npm) & (make -C front-end NPM="run watch:js" npm) & (cd content && ../website watch)'


CONTENT := $(shell find content)
build: website install
	$(RUN) bash -c 'rm -rf ./content/scripts/'
	$(RUN) bash -c 'mkdir ./content/scripts/'
	$(RUN) bash -c 'cd content && ../website build'
	$(RUN) bash -c 'make -C front-end NPM="run css" npm && make -C front-end NPM="run fonts" npm'
	$(RUN) bash -c 'make -C front-end NPM="run build:js" npm && make -C front-end NPM="run build:fonts" npm'
	$(RUN) bash -c 'mkdir -p ./_site/assets'
	$(RUN) bash -c 'cp ./content/stylesheets/dragonfly.css \
		./_site/assets/dragonfly.css; \
		cp ./content/scripts/*.js ./_site/assets/; \
		cp -rf ./content/fonts ./_site/fonts'

install:
	$(RUN) bash -c 'make -C front-end NPM="install" npm'

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


clean:
	rm -f website && rm -rf _site .cache && \
	rm -f content/stylesheets/dragonfly.css* && \
	rm -f content/fonts/* && \
	rm -f content/scripts/*.js*

compress:
	$(RUN) bash -c 'tar -czf static-site.tgz _site/*'
