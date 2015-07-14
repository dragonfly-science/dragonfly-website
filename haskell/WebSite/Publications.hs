{-# LANGUAGE OverloadedStrings #-}
module WebSite.Publications (
    rules
) where

import Control.Monad (liftM)
import Data.Monoid ((<>))
import Data.Maybe (fromMaybe)

import Text.CSL (readBiblioFile)
import Text.CSL.Reference (Reference)

import Hakyll

import WebSite.Bibliography
import WebSite.Collection hiding (getList)
import WebSite.Context
import WebSite.Compilers
import WebSite.DomUtil.Images

cc     = CollectionConfig
       { baseName            = "publications"
       , indexTemplate       = "publications/index.html"
       , indexPattern        = "pages/publications.md"
       , collectionPattern   = "publications/*.md"
       , collectionTemplate  = "templates/publication-list.html"
       , pageTemplate        = "templates/publication.html"
       }

rules :: Rules()
rules = do

    match (indexPattern cc) $ do
        route $ constRoute (indexTemplate cc)
        compile $ do
            base <- baseContext (baseName cc)
            bib <- biblioContext
            pages <- getList cc 1000
            let  ctx = base <> bib <> pages
            scholmdCompiler
                >>= loadAndApplyTemplate (collectionTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match (collectionPattern cc) $ version "full" $ do
        compile $ do
            scholmdCompiler
                >>= saveSnapshot "content"

    match (collectionPattern cc) $ do
        route $ setExtension "html"
        compile $ do
            ident <- getUnderlying
            base <- baseContext (baseName cc)
            ref <- refContext
            imageMeta <- loadAll ("**/*.img.md")
            let ctx = base <> ref
            scholmdCompiler
                >>= loadAndApplyTemplate (pageTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= relativizeUrls

getList :: CollectionConfig -> Int -> Compiler (Context String)
getList cc limit = do
    ref <- refContext
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
    let sortorder i = liftM (fromMaybe "666") $ getMetadataField i "sortorder"
    snaps' <- sortItemsBy sortorder snaps
    let l = length snaps'
        all = cycle snaps'
    return $ listField (baseName cc) (ctx ref) (return $ take limit snaps')

imageCredits :: [Item String] -> Item String -> Compiler (Item String)
imageCredits imgMeta item = do
    return $ fmap (processFigures) item

ctx :: Context String -> Context String
ctx base = base <> bodyField "body" <> metadataField
