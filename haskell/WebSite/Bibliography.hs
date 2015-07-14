{-# LANGUAGE RecordWildCards #-}
module WebSite.Bibliography (
  biblioCitations,
  biblioCitationsByYear,
  lookupRef,
  refCitation,
  refTitle,
  refUrl,
  refDoi,
  refId,
  refPath,
) where

import Data.Char (isSpace)
import Data.List (find, sortOn)
import GHC.Exts (build)
import System.Directory (doesFileExist)
import System.FilePath (takeBaseName)
import Text.CSL.Reference (Reference)
import qualified Text.CSL.Reference as Ref
import Text.CSL.Style (Formatted(unFormatted), Agent(..))
import Text.Pandoc.Shared (stringify)

import WebSite.Compilers (renderPandocBiblio)

import Hakyll

-- | Look up the BibTeX ID part of an identifier in a bibliography to see if
-- there is a reference.
lookupRef :: Identifier -> Item Biblio -> Maybe Reference
lookupRef ident item | Biblio refs <- itemBody item = do
    -- Get the BibTeX ID from the path.
    let bibtexId = takeBaseName $ toFilePath ident
    -- Find the matching reference ID in the bibliography.
    find ((== bibtexId) . refId) refs

filterBiblio :: (Reference -> Bool) -> Item Biblio -> Item Biblio
filterBiblio c = fmap $ \(Biblio refs) -> Biblio (filter c refs)

sortBiblioOn :: Ord a => (Reference -> a) -> Item Biblio -> Item Biblio
sortBiblioOn f = fmap $ \(Biblio refs) -> Biblio (sortOn f refs)

biblioByKeyword :: String -> Item Biblio -> Item Biblio
biblioByKeyword kw = filterBiblio (elem kw . keywords . unformat . Ref.keyword)

biblioCitations :: Item CSL -> Item Biblio -> Compiler String
biblioCitations csl bib | Biblio refs <- itemBody bib = refCitations csl bib refs

biblioCitationsByYear :: Item CSL -> Item Biblio -> Int -> Compiler String
biblioCitationsByYear csl bib yr = biblioCitations csl $
                                   sortBiblioOn refAuthorsSorted $
                                   filterBiblio ((== show yr) . refYear) bib

-- | Extract a comma-delimited (and arbitrarily spaced) list of words
keywords :: String -> [String]
keywords s = build (\c n -> keywords' c n s)
  where
    isSep c = isSpace c || c == ','
    keywords' cons nil = go
      where
        go s = case dropWhile isSep s of
            "" -> nil
            s' -> let (w, s'') = break isSep s' in w `cons` go s''

-- | Render references as HTML citations
refCitations :: Item CSL -> Item Biblio -> [Reference] -> Compiler String
refCitations csl bib = fmap concat . mapM (refCitation csl bib)

-- | Render a reference as an HTML citation
refCitation :: Item CSL -> Item Biblio -> Reference -> Compiler String
refCitation csl bib ref = asItem dummyInput (renderPandocBiblio csl bib)
  where
    -- The input is an empty body with dummy metadata to get Pandoc to generate
    -- the HTML for the reference.
    dummyInput = unlines ["---", "nocite: |", ' ':' ':'@':refId ref, "..."]

-- | Render the unformatted title of a reference
refTitle :: Reference -> String
refTitle = unformat . Ref.title

-- | Render the URL of a reference
refUrl :: Reference -> String
refUrl = Ref.unLiteral . Ref.url

-- | Render the DOI of a reference
refDoi :: Reference -> String
refDoi = Ref.unLiteral . Ref.doi

-- | BibTeX identifier of a reference
refId :: Reference -> String
refId = Ref.unLiteral . Ref.refId

-- | File path of a reference summary page
refPath :: Reference -> FilePath
refPath ref = "publications/" ++ refId ref ++ ".md"

-- | Issue year of a reference.
--
-- Note that the Reference type has a number of date fields. This assumes the
-- desired year is always in the 'issued' field and that there is only one entry
-- in its list.
refYear :: Reference -> String
refYear ref
  | [Ref.RefDate {Ref.year = Ref.Literal yr}] <- Ref.issued ref = yr
  | otherwise = "unknown year"

-- | Sortable text for ordering a bibliography by authors
refAuthorsSorted :: Reference -> [[String]]
refAuthorsSorted = map agentSortOrder . Ref.author

-- | Sortable text for ordering authors
--
-- FIXME! This doesn't properly handle all the naming structures produced by
-- Pandoc.
agentSortOrder :: Agent -> [String]
agentSortOrder Agent{..} = unformat familyName : map unformat givenName

unformat :: Formatted -> String
unformat = stringify . unFormatted

asItem :: a -> (Item a -> Compiler (Item b)) -> Compiler b
asItem x f = makeItem x >>= f >>= return . itemBody
