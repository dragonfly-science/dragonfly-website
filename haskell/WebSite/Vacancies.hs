{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE FlexibleContexts #-}

module WebSite.Vacancies (
    rules, list
) where

import           Data.List            (sortOn)
import           Data.Maybe           (fromMaybe)
import           Data.Monoid          ((<>))

import           Hakyll

import           WebSite.Collection
import           WebSite.Compilers
import           WebSite.Config
import           WebSite.Context
import           WebSite.Validate     (validatePage)

config = CollectionConfig
       { baseName            = "vacancies"
       , indexTemplate       = "vacancies/index.html"
       , indexPattern        = "vacancies.md"
       , collectionPattern   = "vacancies/**/content.md"
       , collectionTemplate  = "templates/vacancies-list.html"
       , pageTemplate        = "templates/vacancies.html"
       }

rules :: Rules()

rules = do

  match (indexPattern config) $ do
    route $ constRoute (indexTemplate config)
    compile $ do
      base <- baseContext (baseName config)
      pages <- getList config 1000

      let ctx = base
                <> teaserImage
                <> socialImage
                <> actualbodyField "actualbody"
                <> pages

      scholmdCompiler
        >>= loadAndApplyTemplate (collectionTemplate config) ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= validatePage

  match (collectionPattern config) $ do
    compile $ do
      scholmdCompiler
        >>= saveSnapshot "content"

  match (collectionPattern config) $ version "output" $ do
    route $ setExtension "html"
    compile $ do
      base <- baseContext (baseName config)

      let ctx = base <> actualbodyField "actualbody"
      scholmdCompiler
          >>= loadAndApplyTemplate (pageTemplate config) ctx
          >>= loadAndApplyTemplate "templates/default.html" ctx

list = getList config
