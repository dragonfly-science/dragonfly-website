{-# LANGUAGE OverloadedStrings #-}
module WebSite.News (
    rules, list
) where

import           WebSite.Collection

config = CollectionConfig
       { baseName            = "news"
       , indexTemplate       = "news/index.html"
       , indexPattern        = "news.md"
       , collectionPattern   = "news/**/content.md"
       , collectionTemplate  = "templates/news-list.html"
       , pageTemplate        = "templates/news.html"
       }

rules :: Rules()
rules = makeRules config

list = getList config
