{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
module WebSite.Collection (
    makeRules,
    getList, 
    pageIndexCtx,
    getBubbles,
    CollectionConfig(..),
    Rules()
) where

import Data.List
import Control.Monad (liftM)
import Data.Monoid ((<>))
import Data.Maybe (fromMaybe, maybeToList)
import Control.Monad.Error.Class
import System.FilePath
import Data.Time.Locale.Compat (defaultTimeLocale)
import Data.Time.Clock (utctDay)
import Data.Time.Calendar (toModifiedJulianDay)

import Text.Pandoc

import Hakyll

import WebSite.Context
import WebSite.Compilers

data CollectionConfig = CollectionConfig 
                      { baseName           :: String
                      , indexTemplate      :: FilePath
                      , indexPattern       :: Pattern
                      , collectionPattern  :: Pattern
                      , collectionTemplate :: Identifier
                      , pageTemplate       :: Identifier
                      }

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
            imageMeta <- loadAll ("**/*.img.md")
            pages <- getList cc 1000
            bubbles <- getBubbles cc (Just ident)
            pandoc <- readScholmd
            let ctx = base <> actualbodyField "actualbody" <> pages <> bubbles
            writeScholmd pandoc
                >>= loadAndApplyTemplate "templates/append-publications.html" ctx
                >>= loadAndApplyTemplate (pageTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= relativizeUrls

getList :: CollectionConfig -> Int ->  Compiler (Context String)
getList cc limit = do
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
    let sortorder i = do so <- getMetadataField i "sortorder" 
                         days <- (do utc <- getItemUTC defaultTimeLocale i
                                     return (( negate . toModifiedJulianDay . utctDay) utc)
                                  ) `catchError` (\_ -> return 666)
                         return (maybe days read so)   -- TODO: read will error if sortorder is not readable as integer
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
pageIndexCtx lu  = listContextWith "tags" tagContext
                <> defaultContext 
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

-- Sort items by a monadic ordering function
sortItemsBy :: (Ord b, Monad m) => (Identifier -> m b) -> [Item a] -> m [Item a]
sortItemsBy f = sortByM $ f . itemIdentifier
  where
    sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
    sortByM f xs = map fst . sortOn snd <$> mapM (\x -> (x,) <$> f x) xs

