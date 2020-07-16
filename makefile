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
	$(RUN) bash -c 'npm run build & (cd content/stylesheets && find . -name \*.css -not -name dragonfly.css \
		| npm run watch:css) & (cd content && npm run watch:js) & (cd content && ../website watch)'


CONTENT := $(shell find content)
build: website install
	$(RUN) bash -c 'rm -rf ./content/scripts/'
	$(RUN) bash -c 'mkdir ./content/scripts/'
	$(RUN) bash -c 'cd content && ../website build'
	$(RUN) bash -c 'npm run css && npm run fonts'
	$(RUN) bash -c 'npm run build:js && npm run build:fonts'
	$(RUN) bash -c 'mkdir -p ./_site/assets'
	$(RUN) bash -c 'cp ./content/stylesheets/dragonfly.css \
		./_site/assets/dragonfly.css; \
		cp ./content/scripts/*.js ./_site/assets/; \
		cp -rf ./content/fonts ./_site/fonts'


CSS := $(shell find content/stylesheets -name *.css -not -name dragonfly.css)
content/stylesheets/dragonfly.css: content/stylesheets/main.src.css $(CSS)
	$(RUN) bash -c 'npm run css && npm run fonts'

install:
	$(RUN) bash -c 'npm install $(ADD)'

npm:
	$(RUN) bash -c 'npm $(NPM)'

audit:
	$(RUN) bash -c 'npm audit fix'

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
