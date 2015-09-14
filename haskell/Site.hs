{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid          ((<>))

import           Hakyll

import           WebSite.Compilers
import           WebSite.Config
import           WebSite.Context
import qualified WebSite.Images       as Images
import qualified WebSite.Data         as Data
import qualified WebSite.News         as News
import qualified WebSite.People       as People
import qualified WebSite.Publications as Publications
import qualified WebSite.Work         as Work

config :: Configuration
config = defaultConfiguration {
  destinationDirectory = "/tmp/cache/dragonflyweb/main/site",
  storeDirectory       = "/tmp/cache/dragonflyweb/main/cache",
  tmpDirectory         = "/tmp/cache/dragonflyweb/main/cache/tmp",
  previewHost          = "0.0.0.0"
}

main :: IO ()
main = hakyllWith config $ do

    match "templates/*" $ compile templateCompiler

    match (fromList [cslIdentifier, cslNoBibIdentifier]) $ compile cslCompiler
    match (fromList [bibIdentifier]) $ compile biblioCompiler

    match "**/*.img.md" $ compile scholmdCompiler
    match ("images/*" .||.  "google*.html" .||. "**/*.jpg" .||. "**/*.png") $ do
        route idRoute
        compile copyFileCompiler

    -- Process images through imagemagick
    -- for each <name> and <args> we get a image
    --   some/path/image.jpg -> some/path/name-image.jpg
    -- created by running convert <args> on the image
    -- Make images at each of the CSS breakpoints
    -- full:  1088
    -- large:  960
    -- medium: 720
    -- small-medium: 560
    -- small: 420
    Images.imageProcessor ( "**/*.jpg" .||. "**/*.png") $ 
                          [ ( "420", ["-resize" , "420"]) 
                          , ( "560", ["-resize" , "560"]), 
                          , ( "720", ["-resize" , "720"]),
                          , ( "960", ["-resize" , "960"]), 
                          , ("1088", ["-resize" , "1088"]), 
                          , ("1600", ["-resize" , "1600"])
                          ]

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

    -- Data section
    Data.rules

    -- Publications section
    Publications.rules

    -- Contact page
    match "pages/contact.html" $ do
        route $ constRoute "contact/index.html"
        compile $ do
            ctx <- baseContext "contact"
            scholmdCompiler
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- Standalone pages
    match "pages/*.md" $ do
        route $ setExtension "html"
        compile $ do
            ctx  <- baseContext "index"
            scholmdCompiler
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
        
    -- Static files
    match "assets/*" $ do
        route idRoute
        compile copyFileCompiler

    match "favicon.ico" $ do
        route idRoute
        compile copyFileCompiler


