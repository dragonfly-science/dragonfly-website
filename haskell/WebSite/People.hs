{-# LANGUAGE OverloadedStrings #-}
module WebSite.People (
    rules, list, bubbles
) where

import           Hakyll

import           WebSite.Collection

config =  CollectionConfig
       { baseName            = "people"
       , indexTemplate       = "people/index.html"
       , indexPattern        = "pages/people.md"
       , collectionPattern   = "people/*.md"
       , collectionTemplate  = "templates/people-list.html"
       , pageTemplate        = "templates/person.html"
       }

rules :: Rules()
rules = makeRules config

list :: Int -> Compiler (Context String)
list = getList config

bubbles = getBubbles config (Just "people/finlay-thompson.html")
