{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE ScopedTypeVariables #-}
module WebSite.Careers (
    rules, list
) where

import           Data.List            (sortOn)
import           Data.Maybe           (fromMaybe)
import           Data.Monoid          ((<>), mconcat)

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
      pages <- getList config 1000

      let ctx = base <> pages <> teaserImage <> socialImage

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
        pandoc <- readScholmd

        let getPerson itm = do
              md <- getMetadata $ itemIdentifier itm
              case lookupStringList "person" md of
                Just person -> mapM (load . fromFilePath) person
                Nothing -> return []
            person = listFieldWith "person" itemCtx getPerson

        let ctx = base <> person
        writeScholmd pandoc
            >>= loadAndApplyTemplate (pageTemplate config) ctx
            >>= loadAndApplyTemplate "templates/default.html" ctx

list = getList config
