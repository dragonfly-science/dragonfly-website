{-# LANGUAGE OverloadedStrings #-}
module WebSite.Context (
  baseContext,
  actualbodyField,
  pageUrlField,
  refContext,
  biblioContext
) where

import Control.Monad (forM)
import Data.Monoid ((<>))
import System.FilePath (takeBaseName, replaceExtension)
import Text.CSL.Reference (Reference)

import WebSite.Bibliography

import Hakyll

baseContext :: String -> Compiler (Context String)
baseContext section = do
    path <- fmap toFilePath getUnderlying
    return $  dateField  "date"   "%B %e, %Y"
           <> constField "jquery" "//ajax.googleapis.com/ajax/libs/jquery/2.0.3"
           <> constField "section" section
           <> constField ("on-" ++ takeBaseName path) ""
           <> bodyField "body"
           <> metadataField
           -- We don't include titleField (or defaultContext which includes
           -- titleField) here because (1) we never want the file name as the
           -- title and (2) we want to use the title from citations.

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

-- Provide context for all references
biblioContext :: Compiler (Context String)
biblioContext = do
    csl <- load "resources/bibliography/apa.csl"
    bib <- load "resources/bibliography/mfish.bib"
    return $ field "citations-by-year" $ const $
        fmap mconcat $ forM [2015,2014..2007] $ \yr ->
            mappend <$> pure ("<h2>" ++ show yr ++ "</h2>")
                    <*> biblioCitationsByYear csl bib yr

-- Provide context for a single BibTeX reference
refContext :: Compiler (Context String)
refContext = do
    csl <- load "resources/bibliography/apa.csl"
    bib <- load "resources/bibliography/mfish.bib"
    return $  refField "title" (failOnNull "title" refTitle) bib
           <> refField "citation" (refCitation csl bib) bib
           <> refField "refUrl" (failOnNull "refUrl" refUrl) bib
           <> refField "doi" (failOnNull "doi" refDoi) bib

refField :: String -> (Reference -> Compiler String) -> Item Biblio -> Context String
refField k showFieldM bib =
    field k (maybe (fail "") showFieldM . flip lookupRef bib . itemIdentifier)

failOnNull :: String -> (Reference -> String) -> Reference -> Compiler String
failOnNull fieldName showField ref
  | s <- showField ref, not (null s) = return s
  | otherwise = fail $ "No '" ++ fieldName ++ "' field for reference '" ++ refId ref ++ "'"
