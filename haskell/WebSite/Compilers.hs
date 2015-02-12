{-# LANGUAGE OverloadedStrings #-}
module WebSite.Compilers (
                         scholmdCompiler,
                         ) where


import Hakyll
import Text.Pandoc.Options
import Control.Applicative


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
    csl <- load $ maybe "resources/biblio/apa.csl" fromFilePath cslfile
    bib <- load $ maybe "resources/biblio/dragonfly-bibliography.yaml" fromFilePath bibfile

    -- I think this is going to be the easiest place to carry out filtering
    -- apply a filter to `bibfile` and then pass the results of the filter to
    -- readPandocBiblio.
    -- this means that we will potentially land up with a list of reference set and will
    -- need to process all of them.


    writePandocWith htm5Writer  <$> (readPandocBiblio def csl bib =<< getResourceBody )

