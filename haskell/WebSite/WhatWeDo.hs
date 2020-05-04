{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE FlexibleContexts #-}

module WebSite.WhatWeDo (
    rules, list
) where
import Debug.Trace
import           Data.List            (sortOn)
import           Data.Maybe           (fromMaybe)
import           Data.Monoid          ((<>))
import           Hakyll

-- import           WebSite.Bibliography
import           WebSite.Collection
import           WebSite.Compilers
import           WebSite.Config
import           WebSite.Context
import           WebSite.Validate     (validatePage)

config = CollectionConfig
       { baseName            = "whatwedo"
       , indexTemplate       = "what-we-do/index.html"
       , indexPattern        = "what-we-do.md"
       , collectionPattern   = "what-we-do/**/content.md"
       , collectionTemplate  = "templates/what-we-do-list.html"
       , pageTemplate        = "templates/what-we-do.html"
       }

makePath :: String -> FilePath
makePath path = path

rules :: Rules()
-- rules = makeRules config

rules = do
    match (indexPattern config) $ do
        route $ constRoute (indexTemplate config)
        compile $ do
            base <- baseContext (baseName config)
            pages <- getList config 1000

            let  ctx = base <> pages
            scholmdCompiler
                >>= loadAndApplyTemplate (collectionTemplate config) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= validatePage

    match (collectionPattern config) $ do
        compile $ do
            scholmdCompiler
                >>= saveSnapshot "content"

    match (collectionPattern config) $ version "output" $ do
        route $ gsubRoute "/content.md" (const ".html")
        compile $ do
            ident <- getUnderlying
            base <- baseContext (baseName config)
            imageMeta <- loadAll ("**/*.img.md")
            pandoc <- readScholmd

            -- Tile definition
            let getTiles itm = do
                  md <- getMetadata $ itemIdentifier itm
                  case lookupStringList "tiles" md of
                    Just tiles -> mapM (load . fromFilePath) tiles
                    Nothing -> return []
                tiles = listFieldWith "tiles" itemCtx getTiles
            
            -- author definition
            let getAuthor itm = do
                  md <- getMetadata $ itemIdentifier itm
                  case lookupStringList "author" md of
                    Just author -> mapM (load . fromFilePath) author
                    Nothing -> return []
                author = listFieldWith "author" itemCtx getAuthor

            let ctx = base
                        <> author
                        <> tiles
                        <> teaserImage
                        <> socialImage
                        <> actualbodyField "actualbody"
            writeScholmd pandoc
                >>= loadAndApplyTemplate (pageTemplate config) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= validatePage

list = getList config
