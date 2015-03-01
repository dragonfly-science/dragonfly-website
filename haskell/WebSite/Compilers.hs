{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
module WebSite.Compilers (
                         scholmdCompiler,
                         sortItemsBy
                         ) where


import Hakyll
import Text.Pandoc.Options
import Control.Applicative
import Control.Monad   (liftM)
import Data.List       (sortBy)
import Data.Ord        (comparing)


htm5Writer :: WriterOptions
htm5Writer = defaultHakyllWriterOptions {
    writerHtml5             = True
    ,writerSectionDivs      = True
}

scholmdCompiler :: Compiler (Item String)
scholmdCompiler = do
    ident <- getUnderlying
    bibfile <- getMetadataField ident "bibliography"
    cslfile <- getMetadataField ident "cslfile"
    -- TODO: should get this from config
    csl <- load $ maybe "resources/bibliography/apa.csl" fromFilePath cslfile
    bib <- load $ maybe "resources/bibliography/mfish.bib" fromFilePath bibfile

    -- I think this is going to be the easiest place to carry out filtering
    -- apply a filter to `bibfile` and then pass the results of the filter to
    -- readPandocBiblio.
    -- this means that we will potentially land up with a list of reference set and will
    -- need to process all of them.


    writePandocWith htm5Writer  <$> (readPandocBiblio def csl bib =<< getResourceBody )


-- Utility function to allow arbitrary sort order for items
sortItemsBy :: (Ord b, MonadMetadata m) => (Identifier -> m b) -> [Item a] -> m [Item a]
sortItemsBy f = sortByM $ f . itemIdentifier
  where
    sortByM :: (Monad m, Ord k) => (a -> m k) -> [a] -> m [a]
    sortByM f xs = liftM (map fst . sortBy (comparing snd)) $
                   mapM (\x -> liftM (x,) (f x)) xs
