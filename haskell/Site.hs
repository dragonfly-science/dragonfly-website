{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid ((<>))

import Hakyll

import WebSite.Context
import WebSite.Compilers
import qualified WebSite.Work as Work
import qualified WebSite.People as People
import qualified WebSite.News as News
import qualified WebSite.Resources as Resources

config :: Configuration
config = defaultConfiguration {
  destinationDirectory = "/var/cache/dragonflyweb/main/site",
  storeDirectory       = "/var/cache/dragonflyweb/main/cache",
  tmpDirectory         = "/var/cache/dragonflyweb/main/cache/tmp",
  previewHost          = "0.0.0.0"
}

main :: IO ()
main = hakyllWith config $ do

    match "templates/*" $ compile templateCompiler

    match "resources/bibliography/*.csl" $ compile cslCompiler
    match "resources/bibliography/*.bib" $ compile biblioCompiler
    match "**/*.img.md" $ compile scholmdCompiler
    match ("images/*" .||.  "google*.html" .||. "**/*.jpg" .||. "**/*.png") $ do
        route idRoute
        compile copyFileCompiler

    -- Home page
    match "pages/index.md" $ do
        route $ constRoute "index.html"
        compile $ do
            base   <- baseContext "index"
            people <- People.list 1000
            bubbles <- People.bubbles 
            work   <- Work.list 3
            news   <- News.list 6
            let ctx = base <> people <> work <> news <> bubbles
            scholmdCompiler
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- People section
    People.rules

    -- Work section
    Work.rules

    -- Work section
    News.rules
   
    -- Resources section
    Resources.rules

    -- Contact page
    match "pages/contact.html" $ do
        route $ constRoute "contact/index.html"
        compile $ do
            ctx <- baseContext "contact"
            scholmdCompiler
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    -- Static files
    match "assets/*" $ do
        route idRoute
        compile copyFileCompiler

