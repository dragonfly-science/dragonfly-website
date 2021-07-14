{-# LANGUAGE OverloadedStrings #-}
module WebSite.Testimonials (
    rules, list
) where

import           Hakyll

import           WebSite.Collection

config =  CollectionConfig
       { baseName            = "testimonials"
       , indexTemplate       = "templates/index.html"
       , indexPattern        = "testimonials/content.md"
       , collectionPattern   = "testimonials/**/content.md"
       , collectionTemplate  = "templates/index.html"
       , pageTemplate        = "templates/index.html"
       }

rules :: Rules()
rules = makeRules config

list :: Int -> Compiler (Context String)
list = getList config

