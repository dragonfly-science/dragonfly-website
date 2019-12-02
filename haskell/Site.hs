{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid          ((<>))
import           Data.Foldable        (forM_)
import           System.Process
import System.Exit

import           Hakyll

import           WebSite.Compilers
import           WebSite.Config
import           WebSite.Context
import qualified WebSite.Data         as Data
import qualified WebSite.Images       as Images
import qualified WebSite.News         as News
import qualified WebSite.People       as People
import qualified WebSite.Publications as Publications
import           WebSite.Validate     (validatePage)
import qualified WebSite.Work         as Work

config :: Configuration
config = defaultConfiguration
  { previewHost          = "0.0.0.0"
  , destinationDirectory = "../_site"
  , storeDirectory       = "../.cache"
  , tmpDirectory         = "../.cache/tmp"
  }


main :: IO ()
main = do
  hakyllWith config $ do

    match "templates/*" $ compile templateCompiler

    match (fromList [cslIdentifier, cslNoBibIdentifier]) $ compile cslCompiler
    match (fromList [bibIdentifier]) $ compile biblioCompiler

    match "**/*.img.md" $ compile scholmdCompiler
    match ("images/*" .||.  "google*.html" .||. "**/*.jpg" .||. "**/*.png" .||. "**/*.csv" .||. "fonts/*") $ do
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

    Images.imageProcessor ( "images/dragonfly-wing.png") $
                          [ ( "420", ["-resize" , "420x128^", "-crop", "420"])
                          , ( "960", ["-resize" , "960x128^"])
                          , ("1600", ["-resize" , "1600x128^"])
                          ]
    Images.imageProcessor ( "images/kokako.jpg") $
                          [ ( "420", ["-resize" , "420x240^", "-crop", "420"])
                          , ( "960", ["-resize" , "960x320^"])
                          , ("1600", ["-resize" , "1600"])
                          ]
    Images.imageProcessor ( "**/teaser.jpg") $
                          [ ( "256", ["-resize" , "256x256^", "-gravity", "Center", "-crop", "256x256+0+0"])
                          , ( "100", ["-resize" , "100x100^", "-gravity", "Center", "-crop", "100x100+0+0"])
                          ]

    --Images.imageProcessor ( "**/*.pdf") $
    --                      [ ( "256", ["-density" , "100", "-resize", "256x256^", "-crop", "256x256+0+0"])
    --                      ]

    -- Home page
    match "index.md" $ do
        route $ constRoute "index.html"
        compile $ do
            base   <- baseContext "index"
            people <- People.list 1000
            bubbles <- People.bubbles
            work   <- Work.list 3
            news   <- News.list 6
            let tiles = listField "tiles" base $ sequence
                  [ load "content/news/2017-08-14-kakapo-two/content.md"
                  , load "content/work/INZ-case-study/content.md"
                  , load "content/news/2019-09-25-whitetip-assessment/content.md"
                  , load "content/work/webrear-case-study/content.md"
                  ]
            let ctx = base <> people <> work <> news <> bubbles <> tiles
            scholmdCompiler
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= validatePage

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
                >>= validatePage

    -- Standalone pages
    match "pages/*.html" $ do
        route $ setExtension "html"
        compile $ do
            ctx  <- baseContext "index"
            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx

    -- Sass based stylesheets
    match "stylesheets/dragonfly.css" $ do
        route $ constRoute "assets/dragonfly.css"
        compile copyFileCompiler

    -- Scripts
    match "scripts/dragonfly.js" $ do
        route $ constRoute "assets/dragonfly.js"
        compile copyFileCompiler

    match "favicon.ico" $ do
        route idRoute
        compile copyFileCompiler
