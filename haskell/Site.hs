{-# LANGUAGE OverloadedStrings #-}

import Debug.Trace

import           Data.Monoid          ((<>))
import           Data.Foldable        (forM_)
import           System.Process
import           System.Exit

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
import qualified WebSite.WhatWeDo     as WhatWeDo

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
                          [ ( "1200", ["-resize" , "1200+600^", "-gravity", "Center", "-crop", "1200+6000+0+0", "-quality", "75"])
                          , ( "960", ["-resize" , "960+960^", "-gravity", "Center", "-crop", "960+960+0+0", "-quality", "75"])
                          , ( "480", ["-resize" , "600+600^", "-gravity", "Center", "-crop", "600+600+0+0", "-quality", "75"])
                          , ( "256", ["-resize" , "256x256^", "-gravity", "Center", "-crop", "256x256+0+0", "-quality", "75"])
                          , ( "100", ["-resize" , "100x100^", "-gravity", "Center", "-crop", "100x100+0+0", "-quality", "75"])
                          ]

    -- People hero banners.
    Images.imageProcessor ( "people/**/*-letterbox.jpg") $
                          [ ( "banner", ["-resize" , "1900", "-gravity", "Center", "-crop", "1900", "-quality", "85"])
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

            -- Tile definition
            let getTiles itm = do
                  md <- getMetadata (itemIdentifier itm)
                  case lookupStringList "tiles" md of
                    Just tiles -> mapM (load . fromFilePath) tiles
                    Nothing -> return []
                tiles = listFieldWith "tiles" itemCtx getTiles

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

    -- What we do section
    WhatWeDo.rules
    -- match "pages/what-we-do.html" $ do
    --     route $ constRoute "what-we-do.html"
    --     compile $ do
    --         ctx <- baseContext "what-we-do"
    --         getResourceBody
    --             >>= applyAsTemplate ctx
    --             >>= loadAndApplyTemplate "templates/default.html" ctx

    -- match "pages/what-we-do/*.html" $ do
    --     route $ gsubRoute "pages/" $ const ""
    --     compile $ do
    --         ctx <- baseContext "what-we-do-internal"
    --         getResourceBody
    --             >>= applyAsTemplate ctx
    --             >>= loadAndApplyTemplate "templates/default.html" ctx

    -- Standalone pages
    match "pages/*.html" $ do
        route $ setExtension ""
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
    match "scripts/*.js" $ do
        route $ gsubRoute "scripts/" (const "assets/")
        compile copyFileCompiler

    match "favicon.ico" $ do
        route idRoute
        compile copyFileCompiler

-- cleanRoute :: Routes
-- cleanRoute = customRoute createIndexRoute
--     where
--         createIndexRoute ident = "what-we-do" </> takeBaseName p </> ".html"
--             where p = toFilePath ident