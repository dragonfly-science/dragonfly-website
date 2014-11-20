{-# LANGUAGE OverloadedStrings #-}
module WebSite.Blog (
    rules
) where

import Data.Monoid ((<>))
import System.FilePath
import Hakyll
import Text.HTML.TagSoup as TS

import WebSite.Context
import WebSite.Compilers

imageCredits :: [Item String] -> Item String -> Compiler (Item String)
imageCredits imgMeta item = do
    return $ fmap (processFigures) item
    where
        processFigures :: String  -> String 
        processFigures s = 
            let tags = parseTags s
                [figures] = sections (~== ("<figure>"::String)) tags
                rv = case figures of
                        [] -> s
                        _ -> s
            in rv


rules :: Rules()
rules = do
    
    -- List the blogs
    match "pages/blog.md" $ do
        route $ constRoute "blog/index.html"
        compile $ do 
            base <- baseContext "blog"
            let pages = listField "posts" postIndexCtx (recentFirst =<< loadAllSnapshots ("posts/*.md"  .&&. hasVersion "full") "content")
                ctx = base <> pages
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











        