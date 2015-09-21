# Notes on creating a binary for OS X

```
cabal sandbox init

cd SOMEPLACE_ELSE
git clone git@github.com:vizowl/pandoc-citeproc.git
cd pandoc-citeproc
cabal sandbox init --sandbox=ORIGINAL_DIR/.cabal-sandbox
cabal install  --constraint="pandoc +embed_data_files" --flags='embed_data_files=True'

cd ORIGINAL_DIR
cabal install --only-dependencies
cabal build
```
