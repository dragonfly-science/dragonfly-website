{-# LANGUAGE OverloadedStrings #-}
module WebSite.Context (
  baseContext,
  actualbodyField,
  pageUrlField,
  refContext
) where

import Data.List (find)
import Data.Monoid ((<>))
import System.FilePath (takeBaseName, replaceExtension)

import Text.CSL.Reference (Reference)
import Text.CSL.Style (Formatted(unFormatted))
import qualified Text.CSL.Reference as Ref

import Text.Pandoc.Shared (stringify)

import WebSite.Compilers (renderPandocBiblio)

import Hakyll

baseContext :: String -> Compiler (Context String)
baseContext section = do
    path <- fmap toFilePath getUnderlying
    return $  dateField  "date"   "%B %e, %Y"
           <> constField "jquery" "//ajax.googleapis.com/ajax/libs/jquery/2.0.3"
           <> constField "section" section
           <> constField ("on-" ++ takeBaseName path) ""
           <> defaultContext


teaserSeparator :: String
teaserSeparator = "<!--more-->"

actualbodyField :: String -> Context String
actualbodyField key = field key $ \_ -> do
    value <- getUnderlying >>= load . setVersion (Just "full")
    let body = itemBody value
        parts = splitAll teaserSeparator body
    case parts of
        [] -> return "WARNING there is no body text"
        _  -> return $ last parts

pageUrlField :: String -> Context a
pageUrlField key = field key $ \item -> do
    let pseudoPath = toFilePath (itemIdentifier item)
        path = "/" ++ pseudoPath
    return (replaceExtension path ".html")

-- Provide the reference data as context if the item is a BibTeX reference.
refContext :: Compiler (Context String)
refContext = do
    csl <- load "resources/bibliography/apa.csl"
    bib <- load "resources/bibliography/mfish.bib"
    return $ mkField "title" refTitle bib <>
             mkField "citation" (refCitation csl bib) bib
  where
    mkField k fromRef bib = field k $
        maybe (fail "") fromRef . flip lookupRef bib . itemIdentifier

-- | Look up the BibTeX ID part of an identifier in a bibliography to see if
-- there is a reference.
lookupRef :: Identifier -> Item Biblio -> Maybe Reference
lookupRef ident Item{itemBody = Biblio refs} = do
    -- Get the BibTeX ID from the path.
    let bibtexId = takeBaseName $ toFilePath ident
    -- Find the matching reference ID in the bibliography.
    find ((== bibtexId) . refId) refs

-- | Render the unformatted title of a reference
refTitle :: Reference -> Compiler String
refTitle = return . stringify . unFormatted . Ref.title

-- | Render the citation HTML for a reference
refCitation :: Item CSL -> Item Biblio -> Reference -> Compiler String
refCitation csl bib ref = asItem dummyInput $ renderPandocBiblio csl bib
  where
    -- The input is an empty body with dummy metadata to get Pandoc to generate
    -- the HTML for a reference list with only the one citation.
    dummyInput = unlines ["---", "nocite: |", ' ':' ':'@':refId ref, "..."]

refId :: Reference -> String
refId = Ref.unLiteral . Ref.refId

asItem :: a -> (Item a -> Compiler (Item b)) -> Compiler b
asItem x f = makeItem x >>= f >>= return . itemBody
