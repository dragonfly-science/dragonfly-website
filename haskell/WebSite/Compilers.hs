{-# LANGUAGE OverloadedStrings #-}
module WebSite.Compilers (
                         scholmdCompiler,
                         ) where


import Hakyll
import Text.Pandoc.Options
import Control.Applicative

scholmdCompiler :: Compiler (Item String)
scholmdCompiler = do
    ident <- getUnderlying
    bibfile <- getMetadataField ident "bibliography"
    cslfile <- getMetadataField ident "cslfile"
    -- TODO: should get this from config
    csl <- load $ maybe "resources/biblio/chicago.csl" fromFilePath cslfile
    bib <- load $ maybe "resources/biblio/dragonfly.yaml" fromFilePath bibfile

    writePandoc <$> (readPandocBiblio def csl bib =<< getResourceBody )

