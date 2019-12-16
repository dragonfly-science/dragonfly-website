{-# LANGUAGE OverloadedStrings #-}
module WebSite.Context (
  baseContext,
  actualbodyField,
  pageUrlField,
  itemCtx,
  teaserImage,
  socialImage,
  refContext,
  listContextWith,
  tagContext
) where

import           Control.Monad
import           Data.Aeson
import           Data.List
import           System.FilePath

import qualified Data.Map             as M
import qualified Data.HashMap.Strict  as HM
import qualified Data.Text            as T
import           Data.Maybe
import           Data.Monoid          ((<>))
import           System.FilePath      (replaceExtension, takeBaseName, takeDirectory)
import           Text.CSL.Reference   (Reference)

import           WebSite.Bibliography
import           WebSite.Config
import           WebSite.Util

import           Hakyll

baseContext :: String -> Compiler (Context String)
baseContext section = do
    path <- fmap toFilePath getUnderlying
    ident <- getUnderlying
    route <- getRoute ident
    let prepareUrl :: String -> String
        prepareUrl path = "/" <> (if takeBaseName path == "index"
                                    then takeDirectory path
                                    else path)
    return $  dateField  "date"   "%B %e, %Y"
           <> constField "jquery" "//ajax.googleapis.com/ajax/libs/jquery/2.0.3"
           <> constField "section" section
           <> constField ("on-" ++ takeBaseName path) ""
           <> bodyField "body"
           <> boolField "hasBody" ((/= "") . trim . itemBody)
           <> listContextWith "tags" tagContext
           <> allTags
           <> metadataField
           <> maybe (constField "url" "/") (constField "url" . prepareUrl ) route
           -- We don't include titleField (or defaultContext which includes
           -- titleField) here because (1) we never want the file name as the
           -- title and (2) we want to use the title from citations.

tagLookup :: String -> String
tagLookup tag =
    case lookup tag tagDictionary of
      Just mtag -> mtag
      Nothing -> ""

tagContext :: Context String
tagContext = field "tag" (return . itemBody)
            <> field "tagDisplay" (return . tagLookup . itemBody)


--listField :: String -> Context a -> Compiler [Item a] -> Context b
allTags :: Context String
allTags = listField "allTags" ctx (return $ map (\x -> Item (fromFilePath (fst x)) x ) tagDictionary)
    where ctx = field "tag" (return . fst . itemBody)
            <> field "tagDisplay" (return . snd . itemBody)


listContextWith :: String -> Context String -> Context a
listContextWith s ctx  = listFieldWith s ctx $ \item -> do
    let identifier = itemIdentifier item
    metadata <- getMetadata identifier
    let metas = maybe [] (map trim . splitAll ",") $
              join $ fmap (resultToMaybe . fromJSON) $
                HM.lookup (T.pack s) metadata
    return $ map (\x -> Item (fromFilePath x) x) metas

itemCtx :: Context String
itemCtx  = listContextWith "tags" tagContext
        <> defaultContext
        <> teaserImage
        <> socialImage
        <> teaserField "teaser" "full"
        <> pageUrlField "pageurl"
        <> dateField "published" "%B %d, %Y"

teaserImage :: Context String
teaserImage = field "teaserImage" getImagePath
  where
    getImagePath item = do
        let path = toFilePath (itemIdentifier item)
            base = take ((length path) - 11) path
            ident = fromFilePath $ base </> "teaser.jpg"
        fmap (maybe "" (toUrl . (flip replaceFileName "480-teaser.jpg"))) (getRoute ident)

socialImage :: Context String
socialImage = field "socialImage" getImagePath
    where
    getImagePath item = do
        let path = toFilePath (itemIdentifier item)
            base = take ((length path) - 11) path
            ident = fromFilePath $ base </> "teaser.jpg"
        fmap (maybe "" (toUrl . (flip replaceFileName "1200-teaser.jpg"))) (getRoute ident)

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
    return $
      if isSuffixOf "/content.md" path
         then (take ((length path) - 11) path) ++ ".html"
      else (replaceExtension path ".html")


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
