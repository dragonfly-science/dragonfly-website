{-# LANGUAGE OverloadedStrings #-}

-- | This module contains values related to configuration.
module WebSite.Config where

import qualified Data.List as List

import Hakyll

import Text.Pandoc.Options (WriterOptions(..))

-- | Options for an HTML5 Pandoc writer
htm5Writer :: WriterOptions
htm5Writer = defaultHakyllWriterOptions
    { writerHtml5       = True
    , writerSectionDivs = True
    }


-- Image metadata fields (All Maybe):
-- Owner
-- Credit
-- Url
-- Source
-- Licence
-- Title
-- Description (MD body)

-- Owner: Philipp Capper
-- URL: https://www.flickr.com/photos/flissphil/74545133/
-- Source: Flickr
-- Licence: CC-BY
-- Title: Photograph of Port Napier

-- Licence data structure:
-- Key
-- Description
-- URL
-- Text

-- | recognised tags
tagDictionary :: [(String, String)] 
tagDictionary = [("edward", "Edward Abraham"), 
    ("katrin", "Katrin Berkenbusch"),
    ("philipp", "Philipp Neubauer"),
    ("yvan", "Yvan Richard"),
    ("finlay", "Finlay Thompson"),
    ("richard", "Richard Mansfield"),
    ("risto", "Christopher Knox"),
    ("report", "Report"),
    ("article", "Article"),
    ("presentation", "Presentation"),
    ("dragonfly", "Dragonfly"),
    ("ecology", "Ecology"),
    ("oceanography", "Oceanography"),
    ("marine-biology", "Marine biology"),
    ("marine-mammal", "Marine mammals"),
    ("bycatch", "Bycatch"),
    ("sea-urchin", "Sea urchin"),
    ("paua", "Pāua"),
    ("robin", "Robin"),
    ("benthic", "Benthic"),
    ("acoustic", "Acoustic monitoring"),
    ("fisheries", "Fisheries"),
    ("bayesian", "Bayesian"),
    ("theoretical-biology", "Theoretical biology"),
    ("risk-assessment", "Risk assessment"),
    ("seabird", "Seabirds"),
    ("theoretical-physics", "Theoretical physics")
    ]

-- | These are years of the publications page.
--
-- NOTE: Update this when you want to add the next year.
publicationYears :: [Int]
publicationYears = [2007..2015]

cslIdentifier, cslNoBibIdentifier :: Identifier
cslIdentifier      = "resources/bibliography/apa-note.csl"
cslNoBibIdentifier = "resources/bibliography/apa-nobib.csl"

bibIdentifier :: Identifier
bibIdentifier = "resources/bibliography/mfish.bib"

-- | Make a publication path for a reference ID
mkPublicationPath :: String -> FilePath
mkPublicationPath i = "publications/" ++ i ++ ".md"

-- | Extract the reference ID from a publication identifier
extractRefId :: Identifier -> String
extractRefId i
  | Just s1 <- List.stripPrefix "publications/" $ toFilePath i
  , s2 <- takeWhile (/= '.') s1
  , not (null s2) = s2
  | otherwise = error $ "Identifier '" ++ toFilePath i ++ "' is not a publication"

-- | Make a publication pattern for a reference ID.
mkPublicationPattern :: String -> Pattern
mkPublicationPattern = fromGlob . mkPublicationPath

-- | Make a pattern for a publication PDF
publicationPDFPattern :: Pattern
publicationPDFPattern = "publications/pdf/*.pdf"

allPublicationsPattern :: Pattern
allPublicationsPattern = mkPublicationPattern "*"

allCitationsPattern :: Pattern
allCitationsPattern = allPublicationsPattern .&&. hasVersion citationsVersion

citationsVersion :: String
citationsVersion = "citations"

citationsSnapshot :: Snapshot
citationsSnapshot = "citations"

-- | Identifiers for all the year groups of publications.
allPublicationsByYearIdentifiers :: [Identifier]
allPublicationsByYearIdentifiers =
    map (fromFilePath . mkPublicationPath . mappend "year/" . show) publicationYears

-- | Extract the reference issue year from a publication-by-year identifier
extractRefYear :: Identifier -> Int
extractRefYear i
  | Just s1 <- List.stripPrefix "publications/year/" $ toFilePath i
  , s2 <- takeWhile (/= '.') s1
  , [(yr, "")] <- reads s2 = yr
  | otherwise = error $ "Identifier '" ++ toFilePath i ++ "' does not have a publication year"
