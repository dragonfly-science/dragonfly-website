#!/bin/bash

set -ex
export RUN=

make -C news
# make -C publications

cp news/current-project/deck-map.html /output/news_deck-map.html
cp news/current-project/most-similar-documents.json /output/news_most-similar-documents.json
cp news/current-project/tree.html /output/news_tree.html
cp news/current-project/tree2.html /output/news_tree2.html
cp news/current-project/umap-plot.html /output/news_umap-plot.html

# cp publications/current-project/deck-map.html /output/publications_deck-map.html
# cp publications/current-project/most-similar-documents.json /output/publications_most-similar-documents.json
# cp publications/current-project/tree.html /output/publications_tree.html
# cp publications/current-project/tree2.html /output/publications_tree2.html
# cp publications/current-project/umap-plot.html /output/publications_umap-plot.html


