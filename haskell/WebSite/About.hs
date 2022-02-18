{-# LANGUAGE OverloadedStrings #-}
module WebSite.About (
    rules, list
) where

import           WebSite.Collection

config = CollectionConfig
       { baseName            = "about-us"
       , indexTemplate       = "about-us/index.html"
       , indexPattern        = "about.md"
       , collectionPattern   = "about/**/content.md"
       , collectionTemplate  = "templates/about-us.html"
       , pageTemplate        = "templates/about-us.html"
       }

rules :: Rules()
rules = makeRules config

list = getList config
