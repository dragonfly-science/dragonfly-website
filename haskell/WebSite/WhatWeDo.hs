{-# LANGUAGE OverloadedStrings #-}
module WebSite.WhatWeDo (
    rules, list
) where

import           WebSite.Collection

config = CollectionConfig
       { baseName            = "whatwedo"
       , indexTemplate       = "what-we-do/index.html"
       , indexPattern        = "what-we-do.md"
       , collectionPattern   = "what-we-do/**/content.md"
       , collectionTemplate  = "templates/what-we-do-list.html"
       , pageTemplate        = "templates/what-we-do.html"
       }

rules :: Rules()
rules = makeRules config

list = getList config
