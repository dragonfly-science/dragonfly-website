TAG := lts-12.26-v1
IMAGE := dragonflyscience/dragonfly-website:$(TAG)
RUN ?= docker run --rm -it -p 8000:8000 -u $$(id -u):$$(id -g) -w /work -v $$(pwd):/work $(IMAGE)

## Compile the hakyll executible
HS := $(shell find haskell/WebSite -name *.hs)
website: $(HS) haskell/Site.hs
	$(RUN) bash -c 'cd haskell && stack build && cp $$(stack path --local-install-root)/bin/website ../website'

develop:
	$(RUN) bash -c '(cd content/stylesheets && find . -name \*.scss | entr -r sass dragonfly.scss dragonfly.css) & (cd content && ../website watch)'

clean:
	$(RUN) bash -c 'cd content && ../website clean'

CONTENT := $(shell find content)
build: website content/stylesheets/dragonfly.css
	$(RUN) bash -c 'cd content && ../website build'


CSS := $(shell find content/stylesheets -name *.css -not -name dragonfly.css)
content/stylesheets/dragonfly.css: content/stylesheets/main.src.css $(CSS)
	$(RUN) bash -c 'npm run css && npm run fonts'
	## $(RUN) bash -c 'NODE_ENV=production postcss $< --config ./ -o $@'


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




