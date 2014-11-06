BUILDDIR := /dist

.PHONY: all
all: $(BUILDDIR)/build/dragonflyweb/dragonflyweb $(BUILDDIR)/build/dragonflyweb/locales-en-US.xml

$(BUILDDIR)/setup-config: DragonflyWeb.cabal
	cabal configure --builddir=$(BUILDDIR)

$(BUILDDIR)/build/dragonflyweb/dragonflyweb: $(BUILDDIR)/setup-config \
	haskell/Site.hs \
	$(wildcard haskell/WebSite/*.hs)
	cabal build --builddir=$(BUILDDIR)

$(BUILDDIR)/build/dragonflyweb/locales-en-%.xml: /usr/local/share/x86_64-linux-ghc-7.8.3/pandoc-citeproc-0.4.0.1/locales/locales-en-%.xml
	cp -p $< $@

