{-# LANGUAGE OverloadedStrings #-}
module WebSite.Compilers (
  readScholmd,
  writeScholmd,
  scholmdCompiler,
  imageCredits,
) where

import           Data.Default           (def)

import           Hakyll

import           Text.Pandoc.Definition

import           WebSite.Config
import           WebSite.DomUtil.Images

readScholmd :: Compiler (Item Pandoc)
readScholmd = do
    csl <- load cslIdentifier
    bib <- load bibIdentifier
    Item i pd <- readPandocBiblio def csl bib =<< getResourceString
    let Pandoc m pdbs = pd
    if length pdbs == 1
        then makeItem ( Pandoc  nullMeta  [])
        else return (Item i pd)

writeScholmd :: Item Pandoc -> Compiler (Item String)
writeScholmd = return . writePandocWith htm5Writer

scholmdCompiler :: Compiler (Item String)
scholmdCompiler = readScholmd >>= writeScholmd

-- FIXME: imgMeta is not used. Should it be?
imageCredits :: [Item String] -> Item String -> Compiler (Item String)
imageCredits imgMeta = return . fmap processFigures
