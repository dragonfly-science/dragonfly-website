{-# LANGUAGE OverloadedStrings #-}
module WebSite.Blog (
    rules
) where

import Data.Monoid ((<>))
import System.FilePath

import Hakyll

import WebSite.Context
import WebSite.Compilers

rules :: Rules()
rules = do
    
    -- List the blogs
    match "pages/blog.md" $ do
        route $ constRoute "blog/index.html"
        compile $ do 
            base <- baseContext "blog"
            let pages = listField "posts" postIndexCtx (recentFirst =<< loadAll "posts/*.md")
            let ctx = base <> pages
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/post-list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "posts/*.md" $ do
        route $ setExtension "html"
        compile $ do 
            base <- baseContext "blog"
            let ctx = base 
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/post.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

postIndexCtx :: Context String
postIndexCtx = defaultContext 
            <> dateField "published" "%B %d . %Y"
            <> teaserImage


teaserImage :: Context String
teaserImage = field "teaserImage" getImagePath
  where 
    getImagePath item = do
        let path = toFilePath (itemIdentifier item)
            base = dropExtension path
            ident = fromFilePath $ base </> "teaser.jpg"
        fmap (maybe "" toUrl) (getRoute ident)

