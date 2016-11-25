{-# LANGUAGE OverloadedStrings #-}
module WebSite.Work (
    rules, list
) where

import           WebSite.Collection

config = CollectionConfig
       { baseName            = "work"
       , indexTemplate       = "work/index.html"
       , indexPattern        = "work.md"
       , collectionPattern   = "work/**/content.md"
       , collectionTemplate  = "templates/post-list.html"
       , pageTemplate        = "templates/post.html"
       }

rules :: Rules()
rules = makeRules config

list = getList config
