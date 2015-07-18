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

import WebSite.Config
import WebSite.Util
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
            bib <- load bibIdentifier
            citations <- getCitationsByYearField bib
            let  ctx = base <> citations
            scholmdCompiler
                >>= loadAndApplyTemplate (collectionTemplate cc) ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match allPublicationsPattern $ version citationsVersion $
        compile $ scholmdCompiler >>= saveSnapshot citationsSnapshot

    match allPublicationsByYearPattern $ version citationsVersion $
        compile $ scholmdCompiler >>= saveSnapshot citationsSnapshot

    match allPublicationsPattern $ do
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

    match ("publications/pdf/*.pdf") $ do
        route idRoute
        compile copyFileCompiler

-- | Outer list context: citations grouped by year
getCitationsByYearField :: Item Biblio -> Compiler (Context String)
getCitationsByYearField bib = do
    citations <- getCitationsForYearField bib
    loadAllSnapshots allPublicationsByYearPattern citationsSnapshot
        >>= sortItemsBy reverseRefYear
        >>= listFieldR "publications-by-year" (metadataField <> citations)

-- | Inner list context: citations for one year, sorted by author
getCitationsForYearField :: Item Biblio -> Compiler (Context String)
getCitationsForYearField bib = do
    ref <- refContext
    return $ listFieldWith "publications-for-year" (metadataField <> ref) $ \item -> do
        yr <- read <$> getMetadataField' (itemIdentifier item) "year"
        getCitationsWith (refYearIs bib yr) (reverseRefAuthors bib)

reverseRefYear :: Identifier -> Compiler (Down Int)
reverseRefYear i = Down . read <$> getMetadataField' i "year"

refYearIs :: Item Biblio -> Int -> Identifier -> Bool
refYearIs bib yr ident = maybe False (== yr) $ refYear =<< lookupRef ident bib
