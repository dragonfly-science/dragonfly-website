{-# LANGUAGE OverloadedStrings #-}
module WebSite.Work (
    rules
) where

import Data.Monoid ((<>))
import System.FilePath
import Hakyll

import WebSite.Context
import WebSite.Compilers
import WebSite.DomUtil.Images

imageCredits :: [Item String] -> Item String -> Compiler (Item String)
imageCredits imgMeta item = do
    return $ fmap (processFigures) item


rules :: Rules()
rules = do
    
    -- List the blogs
    match "pages/work.md" $ do
        route $ constRoute "work/index.html"
        compile $ do 
            base <- baseContext "work"
            let pages = listField "posts" postIndexCtx (recentFirst =<< loadAllSnapshots ("work/*.md"  .&&. hasVersion "full") "content")
                ctx = base <> pages
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/post-list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "work/*.md" $ version "full" $ do
        compile $ do 
            scholmdCompiler 
                >>= saveSnapshot "content"

    match "work/*.md" $ do
        route $ setExtension "html"
        compile $ do 
            base <- baseContext "work"
            imageMeta <- loadAll ("**/*.img.md")
            let ctx = base <> actualbodyField "actualbody"
            -- it should be possible to avoid compiling this twice to load the output from
            -- the 'full' version.
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/post.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
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











        
