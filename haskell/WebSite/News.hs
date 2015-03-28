{-# LANGUAGE OverloadedStrings #-}
module WebSite.News (
    rules
) where

import WebSite.Collection

rules :: Rules()
rules = makeRules $ CollectionConfig 
                        { baseName            = "news"
                        , indexTemplate       = "news/index.html"
                        , indexPattern        = "pages/news.md"
                        , collectionPattern   = "news/*.md"
                        , collectionTemplate  = "templates/news-list.html"
                        , pageTemplate        = "templates/news.html"
                        }


