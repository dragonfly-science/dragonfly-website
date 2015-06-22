{-# LANGUAGE OverloadedStrings #-}
module WebSite.Collection (
    makeRules,
    getList, 
    getBubbles,
    CollectionConfig(..),
    Rules()
) where

import Data.List
import Control.Monad (liftM)
import Data.Monoid ((<>))
import Data.Maybe (fromMaybe, maybeToList)
import System.FilePath

import Text.Pandoc

import Hakyll

import WebSite.Context
import WebSite.Compilers
import WebSite.DomUtil.Images

data CollectionConfig = CollectionConfig 
                      { baseName           :: String
                      , indexTemplate      :: FilePath
                      , indexPattern       :: Pattern
                      , collectionPattern  :: Pattern
                      , collectionTemplate :: Identifier
                      , pageTemplate       :: Identifier
                      }

imageCredits :: [Item String] -> Item String -> Compiler (Item String)
imageCredits imgMeta item = do
    return $ fmap (processFigures) item

makeRules :: CollectionConfig -> Rules()
makeRules cc = do

    match (indexPattern cc) $ do
        route $ constRoute (indexTemplate cc)
        compile $ do 
            base <- baseContext (baseName cc)
            pages <- getList cc 1000
            bubbles <- getBubbles cc Nothing
            let  ctx = base <> pages <> bubbles
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
            pages <- getList cc 1000
            bubbles <- getBubbles cc (Just ident)
            let ctx = ref <> base <> actualbodyField "actualbody" <> pages <> bubbles
            scholmdCompiler 
                >>= loadAndApplyTemplate (pageTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= relativizeUrls

getList :: CollectionConfig -> Int ->  Compiler (Context String)
getList cc limit = do
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
    let sortorder i = liftM (fromMaybe "666") $ getMetadataField i "sortorder"  
    snaps' <- sortItemsBy sortorder snaps
    let l = length snaps'
        all = cycle snaps'
        lu = [ (itemIdentifier this, (prev, next))
             | (prev, this, next) <- take l $ drop (l-1) $ zip3 all (drop 1 all) (drop 2 all) ]
    return $ listField (baseName cc) (pageIndexCtx lu)(return $ take limit snaps')

getBubbles :: CollectionConfig -> Maybe Identifier -> Compiler (Context String)
getBubbles cc mident = do 
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
    let sortorder i = liftM (fromMaybe "666") $ getMetadataField i "sortorder"  
    snaps' <- sortItemsBy sortorder snaps
    let l = length snaps'
        all = cycle snaps'
        lu = [ (itemIdentifier this, (prev, next))
             | (prev, this, next) <- take l $ drop (l-1) $ zip3 all (drop 1 all) (drop 2 all) ]
        snaps'' = maybe (take 7 snaps') id $ do 
                    ident <- mident
                    let ident' = setVersion (Just "full") ident
                    idx <- findIndex (\i -> ident' == itemIdentifier i) snaps'
                    let (before, after) = splitAt (idx + l) (cycle snaps')
                    return $ reverse (take 3 (reverse before)) ++ take 4 after
        previous = listField "bubbles_prev" (pageIndexCtx lu)(return (take 3 snaps''))
        this     = listField "bubbles_this" (pageIndexCtx lu)(return (take 1 $ drop 3 snaps''))
        next     = listField "bubbles_next" (pageIndexCtx lu)(return (take 3 $ drop 4 snaps''))
    return  $ previous <> this <> next
    

type PreviousNextMap = [(Identifier, (Item String, Item String))]
pageIndexCtx :: PreviousNextMap -> Context String
pageIndexCtx lu  = defaultContext 
                <> teaserImage
                <> portholeImage
                <> teaserField "teaser" "content"
                <> pageUrlField "pageurl"
                <> dateField "published" "%B %d . %Y"
                <> previous lu
                <> next lu

previous :: PreviousNextMap -> Context String
previous lu = 
    let lup item = return $ fmap fst $ maybeToList $ lookup (itemIdentifier item) lu
    in  listFieldWith "previous" (pageIndexCtx []) lup

next :: PreviousNextMap -> Context String
next lu = 
    let lup item = return $ fmap snd $ maybeToList $ lookup (itemIdentifier item) lu
    in  listFieldWith "next" (pageIndexCtx []) lup

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
