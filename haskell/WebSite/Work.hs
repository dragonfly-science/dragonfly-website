{-# LANGUAGE OverloadedStrings #-}
module WebSite.Work (
    rules
) where

import WebSite.Collection

rules :: Rules()
rules = makeRules $ CollectionConfig 
                        { baseName            = "work"
                        , indexTemplate       = "work/index.html"
                        , indexPattern        = "pages/work.md"
                        , collectionPattern   = "work/*.md"
                        , collectionTemplate  = "templates/post-list.html"
                        , pageTemplate        = "templates/post.html"
                        }


