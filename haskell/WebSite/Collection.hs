{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections     #-}
module WebSite.Collection (
    makeRules,
    getList,
    pageIndexCtx,
    getBubbles,
    CollectionConfig(..),
    Rules()
) where

import           Control.Monad.Except
import           Control.Monad
import qualified Data.HashMap.Strict  as HM
import           Data.Aeson
import           Data.List
import qualified Data.Map                as M
import qualified Data.Text               as T
import           Data.Maybe              (fromMaybe, maybeToList)
import           Data.Monoid             ((<>))
import qualified Data.Set                as S
import           Data.Time.Calendar      (toModifiedJulianDay)
import           Data.Time.Clock         (utctDay)
import           Data.Time.Locale.Compat (defaultTimeLocale)
import           System.FilePath

import           Hakyll

import           WebSite.Compilers
import           WebSite.Util
import           WebSite.Context
import           WebSite.Validate        (validatePage)

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
            tagLists <- getTagLists cc
            bubbles <- getBubbles cc Nothing
            let  ctx = base <> pages <> bubbles <> tagLists
            scholmdCompiler
                >>= loadAndApplyTemplate (collectionTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= validatePage

    match (collectionPattern cc) $ version "full" $ do
        compile $ do
            scholmdCompiler
                >>= saveSnapshot "content"

    match (collectionPattern cc) $ do
        route $ gsubRoute "/content.md" (const ".html")
        compile $ do
            ident <- getUnderlying
            base <- baseContext (baseName cc)
            imageMeta <- loadAll ("**/*.img.md")
            pages <- getList cc 1000
            bubbles <- getBubbles cc (Just ident)
            pandoc <- readScholmd
            let ctx = base <> teaserImage <> actualbodyField "actualbody" <> pages <> bubbles
            writeScholmd pandoc
                >>= loadAndApplyTemplate "templates/append-publications.html" ctx
                >>= loadAndApplyTemplate (pageTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= validatePage

sortorder :: Identifier -> Compiler Integer
sortorder i = do
    so <- getMetadataField i "sortorder"
    days <- (do utc <- getItemUTC defaultTimeLocale i
                return (( negate . toModifiedJulianDay . utctDay) utc)
            ) `catchError` (\_ -> return 666)
    return (maybe days read so)
    -- TODO: read will error if sortorder is not readable as integer

getList :: CollectionConfig -> Int ->  Compiler (Context String)
getList cc limit = do
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
    let filterItems i = liftM (maybe True (/="0")) $ getMetadataField i "sortorder"
    snaps' <- sortItemsBy sortorder =<< filterItemsBy filterItems snaps
    let l = length snaps'
        all = cycle snaps'
        lu = [ (itemIdentifier this, (prev, next))
             | (prev, this, next) <- take l $ drop (l-1) $ zip3 all (drop 1 all) (drop 2 all) ]
    return $ listField (baseName cc) (pageIndexCtx lu)(return $ take limit snaps')

getBubbles :: CollectionConfig -> Maybe Identifier -> Compiler (Context String)
getBubbles cc mident = do
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
    let sortorder i = liftM (fromMaybe "666") $ getMetadataField i "sortorder"
    let filterItems i = liftM (maybe True (/="0")) $ getMetadataField i "sortorder"
    snaps' <- sortItemsBy sortorder =<< filterItemsBy filterItems snaps
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

getTagLists :: CollectionConfig -> Compiler (Context String)
getTagLists cc = do
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"

    -- Get all the tags together, and find unique tags
    let tags :: S.Set String -> Item String -> Compiler (S.Set String)
        tags tagSet i = do
            metadata <- getMetadata $ itemIdentifier i
            let mtags = join $ fmap (resultToMaybe . fromJSON) $ HM.lookup "tags" metadata
                ntags = S.fromList $ maybe [] (map trim . splitAll ",") mtags
            return $ S.union tagSet ntags
    uniquetags <- foldM tags S.empty snaps

    -- foreach tag create a list of items with that tag
    let hasTag tag i = do
            metadata <- getMetadata i
            let mtags = join $ fmap (resultToMaybe . fromJSON) $ HM.lookup "tags" metadata
            return $ S.member tag $ S.fromList $ maybe [] (map trim . splitAll ",") mtags
    let tagList ctx tag = do
            snaps' <- filterItemsBy (hasTag tag) snaps
            let ntags = listField ("tag_"++tag) itemCtx (sortItemsBy sortorder snaps')
            return $ ctx <> ntags
    foldM tagList mempty uniquetags


itemCtx :: Context String
itemCtx  = listContextWith "tags" tagContext
        <> defaultContext
        <> teaserImage
        <> teaserField "teaser" "content"
        <> pageUrlField "pageurl"
        <> dateField "published" "%B %d, %Y"


type PreviousNextMap = [(Identifier, (Item String, Item String))]
pageIndexCtx :: PreviousNextMap -> Context String
pageIndexCtx lu  = itemCtx
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
            base = take ((length path) - 11) path
            ident = fromFilePath $ base </> "teaser.jpg"
        fmap (maybe "" (toUrl . (flip replaceFileName "256-teaser.jpg"))) (getRoute ident)

-- Sort items by a monadic ordering function
sortItemsBy :: (Ord b, Monad m) => (Identifier -> m b) -> [Item a] -> m [Item a]
sortItemsBy f = sortByM $ f . itemIdentifier
  where
    sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
    sortByM f xs = map fst . sortOn snd <$> mapM (\x -> (x,) <$> f x) xs

-- Filter items by a monadic filter function
filterItemsBy :: Monad m => (Identifier -> m Bool) -> [Item a] -> m [Item a]
filterItemsBy f = filterByM $ f . itemIdentifier
  where
    filterByM :: Monad m => (a -> m Bool) -> [a] -> m [a]
    filterByM f xs = map fst . filter snd <$> mapM (\x -> (x,) <$> f x) xs
