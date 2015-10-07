# Developing on a Mac

## Prerequisites

- Install [homebrew](http://brew.sh)
- Install ghc cabal-install ruby and imagemagick

``` brew install ghc cabal-install ruby imagemagick ```

- Install the sass ruby gem

```gem install sass```

## Build Dragonfly website generator

From the base directory of the dragonfly-website checkout

```
cd haskel
cabal sandbox init
cabal install --only-dependencies
cabal build
```

The site generator should now be built at ```dist/build/website/website```

The site generator must be run from the content directory.

```
cd ../content
../haskell/dist/build/website/website watch
```

This will start the preview server on http://localhost:8000/

Sometimes you will see errors about a corrupt cache. Run

```../haskell/dist/build/website/website clean```

## Bibliography submodule

The bibliographic data is in a git submodule. Often if you get an error related to
bibliographics records you just need to update the submodule to the latest version.

``` git submodule update```

