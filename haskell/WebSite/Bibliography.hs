{-# LANGUAGE RecordWildCards #-}
module WebSite.Bibliography (
  lookupRef,
  refCitation,
  refTitle,
  refYear,
  refUrl,
  refDoi,
  refId,
  refAuthorsSorted,
  reverseRefAuthors,
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

import WebSite.Util

import Hakyll

-- | Look up the BibTeX ID part of an identifier in a bibliography to see if
-- there is a reference.
lookupRef :: Identifier -> Item Biblio -> Maybe Reference
lookupRef ident item | Biblio refs <- itemBody item = do
    -- Get the BibTeX ID from the path.
    let bibtexId = takeBaseName $ toFilePath ident
    -- Find the matching reference ID in the bibliography.
    find ((== bibtexId) . refId) refs

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

-- | Issue year of a reference.
--
-- Note that the Reference type has a number of date fields. This assumes the
-- desired year is always in the 'issued' field and that there is only one entry
-- in its list.
refYear :: Reference -> Maybe Int
refYear ref
  | [Ref.RefDate {Ref.year = Ref.Literal s}] <- Ref.issued ref
  , [(yr, "")] <- reads s = Just yr
  | otherwise = Nothing

-- | Sortable text for ordering a bibliography by authors
refAuthorsSorted :: Reference -> [[String]]
refAuthorsSorted = map agentSortOrder . Ref.author

reverseRefAuthors :: Item Biblio -> Identifier -> [[String]]
reverseRefAuthors bib ident = maybe [] refAuthorsSorted $ lookupRef ident bib

-- | Sortable text for ordering authors
--
-- FIXME! This doesn't properly handle all the naming structures produced by
-- Pandoc.
agentSortOrder :: Agent -> [String]
agentSortOrder Agent{..} = unformat familyName : map unformat givenName

unformat :: Formatted -> String
unformat = stringify . unFormatted
