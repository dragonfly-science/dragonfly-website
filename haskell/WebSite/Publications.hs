{-# LANGUAGE OverloadedStrings #-}
module WebSite.Publications (
    rules
) where

import Control.Monad (liftM, when)
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

    create allPublicationsByYearIdentifiers $
        -- Make empty items with the year in the identifier so we can organize
        -- the publications by year.
        compile $ makeItem ("" :: String)

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

    match publicationPDFPattern $ do
        route idRoute
        compile copyFileCompiler

-- | Outer list context: citations grouped by year
getCitationsByYearField :: Item Biblio -> Compiler (Context String)
getCitationsByYearField bib = do
    citations <- getCitationsForYearField bib
    let year = field "year" $ return . show . itemYear
    loadAll (fromList allPublicationsByYearIdentifiers)
        >>= sortItemsBy reverseRefYear
        >>= listFieldR "publications-by-year" (metadataField <> citations <> year)

-- | Inner list context: citations for one year, sorted by author
getCitationsForYearField :: Item Biblio -> Compiler (Context String)
getCitationsForYearField bib = do
    ref <- refContext
    return $ listFieldWith "publications-for-year" (metadataField <> ref) $ \item -> do
        let yr = itemYear item
        citations <- getCitationsWith (refYearIs yr) (reverseRefAuthors bib)
        when (null citations) $
            fail $ "No citations for identifier: " ++ show (itemIdentifier item)
        return citations
  where
    refYearIs :: Int -> Identifier -> Bool
    refYearIs yr ident = maybe False (== yr) $ refYear =<< lookupRef ident bib

itemYear :: Item a -> Int
itemYear = extractRefYear . itemIdentifier

reverseRefYear :: Identifier -> Compiler (Down Int)
reverseRefYear = return . Down . extractRefYear
