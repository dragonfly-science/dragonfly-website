TAG := lts-12.26-v3
IMAGE := dragonflyscience/dragonfly-website:$(TAG)
RUN ?= docker run --rm -it -p 8000:8000 -u $$(id -u):$$(id -g) -w /work -v $$(pwd):/work $(IMAGE)

## Compile the hakyll executible
HS := $(shell find haskell/WebSite -name *.hs)
website: $(HS) haskell/Site.hs
	$(RUN) bash -c 'cd haskell && stack build && cp $$(stack path --local-install-root)/bin/website ../website'

develop: website
	$(RUN) bash -c 'npm run build & (cd content/stylesheets && find . -name \*.css -not -name dragonfly.css | npm run watch:css) & (cd content && ../website watch) & (cd content && npm run watch:js)'


CONTENT := $(shell find content)
build: website npm
	$(RUN) bash -c 'mkdir ./content/scripts/'
	$(RUN) bash -c 'cd content && ../website build'
	$(RUN) bash -c 'npm run css && npm run fonts'
	$(RUN) bash -c 'npm run build:js && npm run fonts:build'
	$(RUN) bash -c 'mkdir -p ./_site/assets'
	$(RUN) bash -c 'cp ./content/stylesheets/dragonfly.css ./_site/assets/dragonfly.css; cp ./content/scripts/app.bundle.js ./_site/assets/app.bundle.js; cp ./content/scripts/vendors~main.bundle.js ./_site/assets/vendors~main.bundle.js'


CSS := $(shell find content/stylesheets -name *.css -not -name dragonfly.css)
content/stylesheets/dragonfly.css: content/stylesheets/main.src.css $(CSS)
	$(RUN) bash -c 'npm run css && npm run fonts'

npm:
	npm install

docker:
	docker build --tag $(IMAGE) .

pull:
	docker pull $(IMAGE)

push:
	docker push $(IMAGE)

local:
	docker run -it --rm -w /work -v $(PWD):/work \
		--net=host \
		-e DISPLAY=$$DISPLAY \
		-e RUN= \
		-v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 \
		-u $$(id -u):$$(id -g) $(IMAGE) bash


clean:
	rm -f website && rm -rf _site .cache && rm -f content/stylesheets/dragonfly.css* && rm -f content/scripts/*.js*


