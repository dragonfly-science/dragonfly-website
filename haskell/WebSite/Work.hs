{-# LANGUAGE OverloadedStrings #-}
module WebSite.Work (
    rules
) where

import Data.Monoid ((<>))
import Data.Maybe (maybeToList)
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
            posts <- getPosts
            let  ctx = base <> posts
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
            posts <- getPosts
            let ctx = base <> actualbodyField "actualbody" <> posts
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/post.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= relativizeUrls

getPosts :: Compiler (Context String)
getPosts = do
    snaps <- loadAllSnapshots ("work/*.md"  .&&. hasVersion "full") "content"
    snaps' <- recentFirst snaps
    let l = length snaps'
        all = cycle snaps'
        lu = [ (itemIdentifier this, (prev, next))
             | (prev, this, next) <- take l $ drop (l-1) $ zip3 all (drop 1 all) (drop 2 all) ]
    return $ listField "posts" (postIndexCtx lu)(return snaps')

type PreviousNextMap = [(Identifier, (Item String, Item String))]
postIndexCtx :: PreviousNextMap -> Context String
postIndexCtx lu  = defaultContext 
                <> dateField "published" "%B %d . %Y"
                <> teaserImage
                <> portholeImage
                <> teaserField "teaser" "content"
                <> pageUrlField "pageurl"
                <> previous lu
                <> next lu

previous :: PreviousNextMap -> Context String
previous lu = 
    let lup item = return $ fmap fst $ maybeToList $ lookup (itemIdentifier item) lu
    in  listFieldWith "previous" (postIndexCtx []) lup

next :: PreviousNextMap -> Context String
next lu = 
    let lup item = return $ fmap snd $ maybeToList $ lookup (itemIdentifier item) lu
    in  listFieldWith "next" (postIndexCtx []) lup

teaserImage :: Context String
teaserImage = field "teaserImage" getImagePath
  where 
    getImagePath item = do
        let path = toFilePath (itemIdentifier item)
            base = dropExtension path
            ident = fromFilePath $ base </> "teaser.jpg"
        fmap (maybe "" toUrl) (getRoute ident)

portholeImage :: Context String
portholeImage = field "portholeImage" getImagePath
  where 
    getImagePath item = do
        let path = toFilePath (itemIdentifier item)
            base = dropExtension path
            ident = fromFilePath $ base </> "porthole.png"
        fmap (maybe "" toUrl) (getRoute ident)










        
