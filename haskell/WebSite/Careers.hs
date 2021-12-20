{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE ScopedTypeVariables #-}
module WebSite.Careers (
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
       { baseName            = "careers"
       , indexTemplate       = "careers/index.html"
       , indexPattern        = "careers.md"
       , collectionPattern   = "careers/**/content.md"
       , collectionTemplate  = "templates/careers-list.html"
       , pageTemplate        = "templates/careers-list.html"
       }

rules :: Rules()

rules = do

  match (indexPattern config) $ do
    route $ constRoute (indexTemplate config)
    compile $ do
      base <- baseContext (baseName config)

      -- Quotes definition
      let getQuotes itm = do
            md <- getMetadata $ itemIdentifier itm
            case lookupStringList "quotes" md of
              Just quote -> mapM (load . fromFilePath) quote
              Nothing -> return []
          quotes = listFieldWith "quotes" itemCtx getQuotes

      let ctx = base <> teaserImage <> quotes

      scholmdCompiler
        >>= loadAndApplyTemplate (pageTemplate config) ctx
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
        ref <- refContext
        let ctx = base <> ref
        scholmdCompiler
            >>= loadAndApplyTemplate (pageTemplate config) ctx
            >>= loadAndApplyTemplate "templates/default.html" ctx

list = getList config
