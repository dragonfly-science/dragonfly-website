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
    return $  refField "title" refTitle bib
           <> refField "citation" (refCitation False csl bib) bib
           <> refField "url" refUrl bib
           <> refField "doi" refDoi bib

refField :: String -> (Reference -> Compiler String) -> Item Biblio -> Context String
refField k fromRef bib = field k $ \item -> do
    x <- maybe (fail "") fromRef . flip lookupRef bib . itemIdentifier $ item
    debugCompiler $ "ref=" ++ show (lookupRef (itemIdentifier item) bib)
    return x
