{-# LANGUAGE OverloadedStrings #-}
module WebSite.Work (
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
       { baseName            = "work"
       , indexTemplate       = "work/index.html"
       , indexPattern        = "landing-pages/work/content.md"
       , collectionPattern   = "work/**/content.md"
       , collectionTemplate  = "templates/post-list.html"
       , pageTemplate        = "templates/post.html"
       }

rules :: Rules()
-- rules = makeRules config

rules = do
    match (indexPattern config) $ do
        route $ constRoute (indexTemplate config)
        compile $ do
            base <- baseContext (baseName config)
            pages <- getList config 1000

            let  ctx = base <> teaserImage <> pages
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
            bubbles <- getBubbles config (Just ident)

            -- Testimonial definition
            let getQuotes itm = do
                  md <- getMetadata $ itemIdentifier itm
                  case lookupStringList "testimonial" md of
                    Just testimonial -> mapM (load . fromFilePath) testimonial
                    Nothing -> return []
                testimonial = listFieldWith "quote" itemCtx getQuotes

            let ctx = base
                        <> testimonial
                        <> teaserImage
                        <> socialImage
                        <> actualbodyField "actualbody"
                        <> bubbles
            writeScholmd pandoc
                >>= loadAndApplyTemplate (pageTemplate config) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= validatePage

list :: Int -> Compiler (Context String)
list = getList config
