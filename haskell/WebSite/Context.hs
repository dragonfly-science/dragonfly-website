{-# LANGUAGE OverloadedStrings #-}
module WebSite.Context (
  baseContext,
  actualbodyField,
  pageUrlField,
  refContext,
  listContextWith,
  tagContext
) where

import Control.Monad (forM, when)
import Data.List (intercalate)
import qualified Data.Map as M
import Data.Monoid ((<>))
import System.FilePath (takeBaseName, replaceExtension)
import Text.CSL.Reference (Reference)
import Text.Pandoc.Definition (Pandoc)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Network.HTTP.Types.URI (urlEncode)

import WebSite.Config
import WebSite.Bibliography

import Hakyll

slugify :: T.Text -> T.Text
slugify = T.intercalate "-"
    . filter (/= "")
    . map wordslug
    . T.words
  where wordslug :: T.Text -> T.Text
        wordslug = T.decodeUtf8
          . urlEncode True
          . T.encodeUtf8
          . T.replace "'" ""
          . T.replace "&" "and"
          . T.replace "(" ""
          . T.replace ")" ""
          . T.replace "," ""
          . T.replace ";" ""
          . T.replace ":" ""
          . T.replace "$m" ""
          . T.replace "$" ""
          . T.replace "=" ""
          . T.replace "%" "pc"
          . T.replace "+" "plus"
          . T.replace "/" "or"
          . T.replace "---" "-"
          . T.toLower

slugify' :: String  -> String
slugify' = T.unpack . slugify . T.pack

baseContext :: String -> Compiler (Context String)
baseContext section = do
    path <- fmap toFilePath getUnderlying
    ident <- getUnderlying
    return $  dateField  "date"   "%B %e, %Y"
           <> constField "jquery" "//ajax.googleapis.com/ajax/libs/jquery/2.0.3"
           <> constField "section" section
           <> constField ("on-" ++ takeBaseName path) ""
           <> bodyField "body"
           <> boolField "hasBody" ((/= "") . trim . itemBody)
           <> listContextWith "tags" tagContext
           <> metadataField
           -- We don't include titleField (or defaultContext which includes
           -- titleField) here because (1) we never want the file name as the
           -- title and (2) we want to use the title from citations.


tagContext :: Context String
tagContext = field "tag" (return . itemBody) 

listContextWith :: String -> Context String -> Context a
listContextWith s ctx  = listFieldWith s ctx $ \item -> do
    let identifier = itemIdentifier item
    metadata <- getMetadata identifier
    let metas = maybe [] (map (slugify' . trim) . splitAll ",") $ M.lookup s metadata
    return $ map (\x -> Item (fromFilePath x) x) metas


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


-- Provide context for a single BibTeX reference
refContext :: Compiler (Context String)
refContext = do
    csl <- load cslIdentifier
    bib <- load bibIdentifier
    return $  refField "title"    (failOnNull "title" refTitle) bib
           <> refField "citation" (refCitation csl bib) bib
           <> refField "refUrl"   (failOnNull "refUrl" refUrl) bib
           <> refField "doi"      (failOnNull "doi" refDoi) bib
           <> refField "abstract" (failOnNull "abstract" refAbstract) bib
           <> refField "year"     (failOnNull "year" (show . maybe 0 id . refYear)) bib
           <> refField "id"       (failOnNull "id" refId) bib

refField :: String -> (Reference -> Compiler String) -> Item Biblio -> Context String
refField k showFieldM bib =
    field k (maybe (fail "") showFieldM . flip lookupRef bib . itemIdentifier)

failOnNull :: String -> (Reference -> String) -> Reference -> Compiler String
failOnNull fieldName showField ref
  | s <- showField ref, not (null s) = return s
  | otherwise = fail $ "No '" ++ fieldName ++ "' field for reference '" ++ refId ref ++ "'"
