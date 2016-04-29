{-# LANGUAGE OverloadedStrings #-}

import           Data.Maybe           (isJust)
import           Data.Monoid          ((<>))
import           System.Environment

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
  fakeImageResize <- lookupEnv "FAKE_IMAGE_RESIZE"
  hakyllWith config $ do

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
    let fir = isJust fakeImageResize

    Images.imageProcessor ( "images/dragonfly-wing.png") $
                          [ ( "420", if fir then [] else ["-resize" , "420x128^", "-crop", "420"])
                          , ( "960", if fir then [] else ["-resize" , "960x128^"])
                          , ("1600", if fir then [] else ["-resize" , "1600x128^"])
                          ]
    Images.imageProcessor ( "images/ipad.jpg") $
                          [ ( "420", if fir then [] else ["-resize" , "420x240^", "-crop", "420"])
                          , ( "960", if fir then [] else ["-resize" , "960x320^"])
                          , ("1600", if fir then [] else ["-resize" , "1600"])
                          ]
    Images.imageProcessor ( "**/teaser.jpg") $
                          [ ( "256", if fir then [] else ["-resize" , "256x256^", "-gravity", "Center", "-crop", "256x256+0+0"])
                          , ( "100", if fir then [] else ["-resize" , "100x100^", "-gravity", "Center", "-crop", "100x100+0+0"])
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
            let ctx = base <> people <> work <> news <> bubbles
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
    match "stylesheets/**.scss" $ do
      compile getResourceBody

    scssDependencies <- makePatternDependency "stylesheets/**.scss"
    rulesExtraDependencies [scssDependencies] $ do
      create ["assets/dragonfly.css"] $ do
        route $ idRoute
        compile $ sassCompiler

    -- Scripts
    match "scripts/dragonfly.js" $ do
        route $ constRoute "assets/dragonfly.js"
        compile copyFileCompiler

    match "favicon.ico" $ do
        route idRoute
        compile copyFileCompiler
