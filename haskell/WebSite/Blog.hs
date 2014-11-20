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
            let pages = listField "posts" postIndexCtx (recentFirst =<< loadAllSnapshots ("posts/*.md"  .&&. hasVersion "full") "content")
            let ctx = base <> pages
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/post-list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "posts/*.md" $ version "full" $ do
        compile $ do 
            scholmdCompiler 
                >>= saveSnapshot "content"

    match "posts/*.md" $ do
        route $ setExtension "html"
        compile $ do 
            base <- baseContext "blog"
            let ctx = base <> actualbodyField "actualbody"
            -- it should be possible to avoid compiling this twice to load the output from
            -- the 'full' version.
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/post.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


postIndexCtx :: Context String
postIndexCtx = defaultContext 
            <> dateField "published" "%B %d . %Y"
            <> teaserImage
            <> teaserField "teaser" "content"
            <> pageUrlField "pageurl"


teaserImage :: Context String
teaserImage = field "teaserImage" getImagePath
  where 
    getImagePath item = do
        let path = toFilePath (itemIdentifier item)
            base = dropExtension path
            ident = fromFilePath $ base </> "teaser.jpg"
        fmap (maybe "" toUrl) (getRoute ident)

teaserSeparator :: String
teaserSeparator = "<!--more-->"


actualbodyField :: String -> Context String
actualbodyField key = field key $ \_ -> do
    value <- getUnderlying >>= load . setVersion (Just "full")
    let body = itemBody value
        parts = splitAll teaserSeparator body
    case parts of
        [] -> return "WARNING there is no body text"
        _  -> return $ last parts

pageUrlField :: String -> Context a
pageUrlField key = field key $ \item -> do
    let pseudoPath = toFilePath (itemIdentifier item)
        path = "/" ++ pseudoPath
    return (replaceExtension path ".html")







        