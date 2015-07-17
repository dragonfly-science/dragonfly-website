{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE FlexibleContexts #-}

-- | This module contains utility values used in other modules.
module WebSite.Util where

import qualified Data.List as List
import qualified Data.Set as Set

import Control.Monad ((>=>))
import Data.Default (def)

import Hakyll

import Text.Pandoc.Definition (Inline(..), Citation(..), Pandoc)
import Text.Pandoc.Options (WriterOptions(..))
import Text.Pandoc.Walk (Walkable(..))

import WebSite.Config

-- | Get a list of citation items after filtering and sorting the bibliography
getCitationsWith :: Ord a => (Identifier -> Bool) -> (Identifier -> a) -> Compiler [Item String]
getCitationsWith filterCond sortCond =
    loadAllSnapshots allCitationsPattern citationsSnapshot
        >>= return . List.sortOn (sortCond   . itemIdentifier)
                   . filter      (filterCond . itemIdentifier)

-- | Get the citation items for a list of citation ID strings
getCitationsById :: Ord a => (Identifier -> a) -> [String] -> Compiler [Item String]
getCitationsById sortCond ids =
    getCitationsWith (flip Set.member (Set.fromList ids) . extractRefId) sortCond

-- | Collection citation IDs from something walkable
collectCitationIds :: Walkable Inline a => a -> [String]
collectCitationIds = List.nub . query go
  where
    go :: Inline -> [String]
    go (Cite citations _) = map citationId citations
    go _                  = []

-- | Options for an HTML5 Pandoc writer
htm5Writer :: WriterOptions
htm5Writer = defaultHakyllWriterOptions
    { writerHtml5       = True
    , writerSectionDivs = True
    }

-- | Render a Pandoc input string to HTML5 output with a CSL style and a
-- bibliography.
renderPandocBiblio
    :: Item CSL
    -> Item Biblio
    -> Item String
    -> Compiler (Item String)
renderPandocBiblio csl bib =
    readPandocBiblio def csl bib >=> return . writePandocWith htm5Writer

-- | Compile something wrapped as an Item
asItem :: a -> (Item a -> Compiler (Item b)) -> Compiler b
asItem x f = makeItem x >>= f >>= return . itemBody

-- Sort items by a monadic ordering function
sortItemsBy :: (Ord b, Monad m) => (Identifier -> m b) -> [Item a] -> m [Item a]
sortItemsBy f = sortByM $ f . itemIdentifier
  where
    sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
    sortByM f xs = map fst . List.sortOn snd <$> mapM (\x -> (x,) <$> f x) xs

listFieldR :: Monad m => String -> Context a -> [Item a] -> m (Context b)
listFieldR name ctx = return . listField name ctx . return
