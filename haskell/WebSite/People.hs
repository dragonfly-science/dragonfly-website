{-# LANGUAGE OverloadedStrings #-}
module WebSite.People (
    rules
) where

import Data.Monoid ((<>))
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
            let persons = listField "pages" personIndexCtx (loadAllSnapshots ("people/*.md"  .&&. hasVersion "full") "content")
            let ctx = base <> persons
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/people-list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    match "people/*.md" $ version "full" $ do
        compile $ do 
            scholmdCompiler 
                >>= saveSnapshot "content"

    match "people/*.md" $ do
        route $ setExtension "html"
        compile $ do
            base <- baseContext "people"
            let banner = constField "banner" "/images/person-banner.png"
            let ctx = base <> banner <> actualbodyField "actualbody"
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/person.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

personIndexCtx :: Context String
personIndexCtx = defaultContext 
                 <> teaserField "teaser" "content"
                 <> pageUrlField "pageurl"
                 <> portholeImage


portholeImage :: Context String
portholeImage = field "portholeImage" getImagePath
  where 
    getImagePath item = do
        let path = toFilePath (itemIdentifier item)
            base = dropExtension path
            ident = fromFilePath $ base </> "porthole.png"
        fmap (maybe "" toUrl) (getRoute ident)

