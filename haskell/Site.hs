{-# LANGUAGE OverloadedStrings #-}

import           Control.Monad
import           Data.Monoid          ((<>))
import           Data.Foldable        (forM_)
import           System.Process
import           System.Exit

import           Hakyll

import           WebSite.Compilers
import           WebSite.Config
import           WebSite.Context
import           WebSite.SiteMap
import qualified WebSite.About        as About
import qualified WebSite.Careers      as Careers
import qualified WebSite.Images       as Images
import qualified WebSite.News         as News
import qualified WebSite.People       as People
import qualified WebSite.Publications as Publications
import qualified WebSite.Testimonials as Testimonials
import qualified WebSite.Vacancies       as Vacancies
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
    match ("images/*"
          .||. "google*.html"
          .||. "**/*.jpg"
          .||. "**/*.png"
          .||. "**/*.svg"
          .||. "**/*.csv"
          .||. "**/*.mp4"
          .||. "fonts/*"
          .||. "landing-pages/**/banner-images/*") $ do
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
                          [ ( "1200", ["-resize" , "1200x600^", "-gravity", "Center", "-crop", "1200x600+0+0", "-quality", "75"])
                          , ( "960", ["-resize" , "960x960^", "-gravity", "Center", "-crop", "960x960+0+0", "-quality", "75"])
                          , ( "960800", ["-resize" , "960x800^", "-gravity", "Center", "-crop", "960x800+0+0", "-quality", "75"])
                          , ( "480", ["-resize" , "480x480^", "-gravity", "Center", "-crop", "480x480+0+0", "-quality", "75"])
                          , ( "600", ["-resize" , "600x600^", "-gravity", "Center", "-crop", "600x600+0+0", "-quality", "75"])
                          , ( "256", ["-resize" , "256x256^", "-gravity", "Center", "-crop", "256x256+0+0", "-quality", "75"])
                          , ( "200", ["-resize" , "200x230^", "-gravity", "Center", "-crop", "200x230+0+0", "-quality", "75"])
                          ]
    Images.imageProcessor ( "**/teaser.png") $
                          [ ( "1200", ["-resize" , "1200x600^", "-gravity", "Center", "-crop", "1200x600+0+0", "-quality", "75"])
                          , ( "960", ["-resize" , "960x960^", "-gravity", "Center", "-crop", "960x960+0+0", "-quality", "75"])
                          , ( "960800", ["-resize" , "960x800^", "-gravity", "Center", "-crop", "960x800+0+0", "-quality", "75"])
                          , ( "480", ["-resize" , "480x480^", "-gravity", "Center", "-crop", "480x480+0+0", "-quality", "75"])
                          , ( "600", ["-resize" , "600x600^", "-gravity", "Center", "-crop", "600x600+0+0", "-quality", "75"])
                          , ( "256", ["-resize" , "256x256^", "-gravity", "Center", "-crop", "256x256+0+0", "-quality", "75"])
                          , ( "200", ["-resize" , "200x230^", "-gravity", "Center", "-crop", "200x230+0+0", "-quality", "75"])
                          ]

    Images.imageProcessor ( "**/teaser-large.jpg") $
                          [ ( "960-landscape", ["-resize" , "410+960^", "-gravity", "Center", "-crop", "410+960+0+0", "-quality", "75"])
                          ]

    -- People hero banners.
    Images.imageProcessor ( "people/**/*-letterbox.jpg") $
                          [ ( "banner", ["-resize" , "1900", "-gravity", "Center", "-crop", "1900", "-quality", "85"])
                          ]

    -- Home page
    match "index.md" $ do
        route $ constRoute "index.html"
        compile $ do
            base   <- baseContext "index"
            people <- People.list 1000
            bubbles <- People.bubbles
            work   <- Work.list 3
            news   <- News.list 4

            -- Section definition
            let getSections itm = do
                  md <- getMetadata (itemIdentifier itm)
                  case lookupStringList "sections" md of
                    Just sections -> mapM (load . fromFilePath) sections
                    Nothing -> return []
                sections = listFieldWith "sections" itemCtx getSections

            -- Tile definition
            let getTiles itm = do
                  md <- getMetadata (itemIdentifier itm)
                  case lookupStringList "tiles" md of
                    Just tiles -> mapM (load . fromFilePath) tiles
                    Nothing -> return []
                tiles = listFieldWith "tiles" itemCtx getTiles

            -- Testimonials definition
            let getTestimonials itm = do
                  md <- getMetadata (itemIdentifier itm)
                  case lookupStringList "testimonials" md of
                    Just testimonials -> mapM (load . fromFilePath) testimonials
                    Nothing -> return []
                testimonials = listFieldWith "testimonials" itemCtx getTestimonials

            let ctx = base
                   <> people
                   <> work
                   <> news
                   <> bubbles
                   <> testimonials
                   <> tiles
                   <> sections

            scholmdCompiler
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= validatePage
    -- Careers
    Careers.rules

    -- People section
    People.rules

    -- Work section
    Work.rules

    -- Work section
    News.rules

    -- About section
    About.rules

    -- Publications section
    Publications.rules

    -- What we do section
    WhatWeDo.rules

    -- Testimonials
    Testimonials.rules

    -- Vacancies
    Vacancies.rules


    -- Standalone pages
    match "pages/*.html" $ do
        route $ setExtension "html"
        compile $ do
            ctx  <- baseContext "index"
            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx

    match "favicon.ico" $ do
        route idRoute
        compile copyFileCompiler

    create ["sitemap.xml"] $ do
        route idRoute
        compile $ do
            news <- recentFirst =<< loadAll ("news/**/*.md")
            people <- loadAll ("people/**/*.md")
            publications <- loadAll ("publications/*.md")
            what <- loadAll ("what-we-do/**/*.md")
            work <- loadAll ("work/**/*.md")

            let pages = news
                     <> people
                     <> publications
                     <> what
                     <> work
                sitemapCtx =
                    constField "root" root <>
                    listField "pages" postCtx (return pages)

            makeItem ""
                >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx
