{-# LANGUAGE OverloadedStrings #-}
module WebSite.Data (
    rules, list
) where

import WebSite.Collection

config = CollectionConfig 
       { baseName            = "data"
       , indexTemplate       = "data/index.html"
       , indexPattern        = "pages/data.md"
       , collectionPattern   = "data/*.md"
       , collectionTemplate  = "templates/data-list.html"
       , pageTemplate        = "templates/post.html"
       }

rules :: Rules()
rules = makeRules config

list = getList config
