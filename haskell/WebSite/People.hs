{-# LANGUAGE OverloadedStrings #-}
module WebSite.People (
    rules
) where

import WebSite.Collection

rules :: Rules()
rules = makeRules $ CollectionConfig 
                        { baseName            = "people"
                        , indexTemplate       = "about/index.html"
                        , indexPattern        = "pages/people.md"
                        , collectionPattern   = "people/*.md"
                        , collectionTemplate  = "templates/people-list.html"
                        , pageTemplate        = "templates/person.html"
                        }


