{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections     #-}
module WebSite.Publications (
    rules
) where

import           Data.List            (sortOn)
import           Data.Monoid          ((<>))


import           Hakyll

import           WebSite.Bibliography
import           WebSite.Collection   hiding (getList)
import           WebSite.Compilers
import           WebSite.Config
import           WebSite.Context
import           WebSite.Validate     (validatePage)

cc     = CollectionConfig
       { baseName            = "publications"
       , indexTemplate       = "publications/index.html"
       , indexPattern        = "publications.md"
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
            citations <- getList cc 1000
            let ctx = citations <> base
            scholmdCompiler
                >>= loadAndApplyTemplate (collectionTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
                >>= validatePage

    match (collectionPattern cc) $ version "full" $ do
        compile $ do
            scholmdCompiler
                >>= saveSnapshot "content"

    match (collectionPattern cc) $ do
        route $ setExtension "html"
        compile $ do
            base <- baseContext (baseName cc)
            ref <- refContext
            imageMeta <- loadAll ("**/*.img.md")
            let ctx = base <> ref
            scholmdCompiler
                >>= loadAndApplyTemplate (pageTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= imageCredits imageMeta
                >>= relativizeUrls
                >>= validatePage

    match publicationPDFPattern $ do
        route idRoute
        compile copyFileCompiler

getList :: CollectionConfig -> Int ->  Compiler (Context String)
getList cc limit = do
    ref <- refContext
    let tags = listContextWith "tags" tagContext
    bib <- load bibIdentifier
    base <- baseContext (baseName cc)
    snaps <- loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
    snaps' <- sortItemsBy (sortorder bib) snaps
    return $ listField (baseName cc) (tags <> base <> ref) (return $ take limit snaps')
    where
      sortorder bib i = do
        case lookupRef i bib of
            Nothing   -> return (0,[])
            Just ref  -> do
                let year = maybe 0 id $ refYear ref
                    author = refAuthorsSorted ref
                return (-year, author)

-- Sort items by a monadic ordering function
sortItemsBy :: (Ord b, Monad m) => (Identifier -> m b) -> [Item a] -> m [Item a]
sortItemsBy f = sortByM $ f . itemIdentifier
  where
    sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
    sortByM f xs = map fst . sortOn snd <$> mapM (\x -> (x,) <$> f x) xs
