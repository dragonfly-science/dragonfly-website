{-# LANGUAGE OverloadedStrings #-}
module WebSite.Resources (
    rules, list
) where

import WebSite.Collection

config = CollectionConfig 
       { baseName            = "resources"
       , indexTemplate       = "resources/index.html"
       , indexPattern        = "pages/resources.md"
       , collectionPattern   = "resources/*.md"
       , collectionTemplate  = "templates/resources-list.html"
       , pageTemplate        = "templates/post.html"
       }

rules :: Rules()
rules = makeRules config

list = getList config
