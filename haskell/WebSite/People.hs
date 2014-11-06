{-# LANGUAGE OverloadedStrings #-}
module WebSite.People (
    rules
) where

import Data.Monoid ((<>), mconcat)
import System.FilePath

import Hakyll

import WebSite.Context
import WebSite.Compilers

rules :: Rules()
rules = do
    
    match "pages/people.md" $ do
        route $ constRoute "people/index.html"
        compile $ do
            base <- baseContext "people"
            let persons = listField "pages" summaryBody (loadAll "people/*.md")
            let ctx = base <> persons
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/people-list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "people/*.md" $ do
        route $ setExtension "html"
        compile $ do
            base <- baseContext "people"
            let banner = constField "banner" "/images/person-banner.png"
            let ctx = base <> banner
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/person.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

summaryBody :: Context String
summaryBody = 
    mconcat [ defaultContext
            , field "summaryBody" $ \item -> do
                  let path = toFilePath (itemIdentifier item)
                      metaFile = dropExtension path </> "meta.md"
                  metaItem <- load $ fromFilePath metaFile
                  return (itemBody metaItem)
            , field "summaryImage" $ \item -> do
                  let path = toFilePath (itemIdentifier item)
                      base = dropExtension path
                      metaIdent = fromFilePath $ base </> "meta.md"
                  imageName <- getMetadataField' metaIdent "image"
                  return (base </> imageName)
            ]

