{-# LANGUAGE OverloadedStrings #-}

-- | This module contains values related to configuration.
module WebSite.Config where

import qualified Data.List as List

import Hakyll

cslIdentifier, cslNoBibIdentifier :: Identifier
cslIdentifier      = "resources/bibliography/apa.csl"
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

allPublicationsPattern :: Pattern
allPublicationsPattern = mkPublicationPattern "*"

allPublicationsByYearPattern :: Pattern
allPublicationsByYearPattern = mkPublicationPattern "year/*"

allCitationsPattern :: Pattern
allCitationsPattern = allPublicationsPattern .&&. hasVersion citationsVersion

allCitationsByYearPattern :: Pattern
allCitationsByYearPattern = allPublicationsByYearPattern .&&. hasVersion citationsVersion

citationsVersion :: String
citationsVersion = "citations"

citationsSnapshot :: Snapshot
citationsSnapshot = "citations"
