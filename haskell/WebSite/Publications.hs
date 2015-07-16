{-# LANGUAGE OverloadedStrings #-}
module WebSite.Publications (
    rules
) where

import Control.Monad (liftM)
import Data.List (sortOn)
import Data.Monoid ((<>))
import Data.Maybe (fromMaybe)
import Data.Ord (Down(..))

import Text.CSL (readBiblioFile)
import Text.CSL.Reference (Reference)

import Hakyll

import WebSite.Bibliography
import WebSite.Collection hiding (getList)
import WebSite.Context
import WebSite.Compilers
import WebSite.DomUtil.Images

cc     = CollectionConfig
       { baseName            = "publications"
       , indexTemplate       = "publications/index.html"
       , indexPattern        = "pages/publications.md"
       , collectionPattern   = "publications/*.md"
       , collectionTemplate  = "templates/publication-list.html"
       , pageTemplate        = "templates/publication.html"
       }

publicationYearsPattern :: Pattern
publicationYearsPattern = "publications/year/*.md"

rules :: Rules()
rules = do

    match (indexPattern cc) $ do
        route $ constRoute (indexTemplate cc)
        compile $ do
            base <- baseContext (baseName cc)
            bib <- load "resources/bibliography/mfish.bib"
            bibCtx <- biblioContext
            citations <- getCitationsByYearField cc bib
            let  ctx = base <> bibCtx <> citations
            scholmdCompiler
                >>= loadAndApplyTemplate (collectionTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match publicationYearsPattern $
        compile $ scholmdCompiler >>= saveSnapshot "content"

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

-- | Get a list of citation items after filtering and sorting the bibliography
getCitations :: Ord a
                => CollectionConfig
                -> (Identifier -> Bool)
                -> (Identifier -> a)
                -> Compiler [Item String]
getCitations cc filterCond sortCond =
    loadAllSnapshots (collectionPattern cc .&&. hasVersion "full") "content"
        >>= return . sortOn (sortCond   . itemIdentifier)
                   . filter (filterCond . itemIdentifier)

-- | Outer list context: citations grouped by year
getCitationsByYearField :: CollectionConfig -> Item Biblio -> Compiler (Context String)
getCitationsByYearField cc bib = do
    citations <- getCitationsForYearField cc bib
    loadAllSnapshots publicationYearsPattern "content"
        >>= sortItemsBy reverseRefYear
        >>= return . listField "publications" (metadataField <> citations) . return

-- | Inner list context: citations for one year, sorted by author
getCitationsForYearField :: CollectionConfig -> Item Biblio -> Compiler (Context String)
getCitationsForYearField cc bib = do
    ref <- refContext
    return $ listFieldWith "publications-for-year" (metadataField <> ref) $ \item -> do
        yr <- read <$> getMetadataField' (itemIdentifier item) "year"
        getCitations cc (refYearIs bib yr) (reverseRefAuthors bib)

reverseRefYear :: Identifier -> Compiler (Down Int)
reverseRefYear i = Down . read <$> getMetadataField' i "year"

reverseRefAuthors :: Item Biblio -> Identifier -> [[String]]
reverseRefAuthors bib ident = maybe [] refAuthorsSorted $ lookupRef ident bib

refYearIs :: Item Biblio -> Int -> Identifier -> Bool
refYearIs bib yr ident = maybe False (== yr) $ refYear =<< lookupRef ident bib

imageCredits :: [Item String] -> Item String -> Compiler (Item String)
imageCredits imgMeta item = do
    return $ fmap (processFigures) item
