{-# LANGUAGE OverloadedStrings #-}
module WebSite.Publications (
    rules, list
) where

import WebSite.Collection

config = CollectionConfig
       { baseName            = "publications"
       , indexTemplate       = "publications/index.html"
       , indexPattern        = "pages/publications.md"
       , collectionPattern   = "publications/*.md"
       , collectionTemplate  = "templates/publication-list.html"
       , pageTemplate        = "templates/publication.html"
       }

rules :: Rules()
rules = makeRules config

list = getList config
