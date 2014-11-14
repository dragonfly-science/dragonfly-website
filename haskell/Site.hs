{-# LANGUAGE OverloadedStrings #-}

import Hakyll

import WebSite.Context
import WebSite.Compilers
import qualified WebSite.Blog as Blog
import qualified WebSite.People as People

config :: Configuration
config = defaultConfiguration {
  destinationDirectory = "/var/cache/dragonflyweb/main/site",
  storeDirectory       = "/var/cache/dragonflyweb/main/cache",
  tmpDirectory         = "/var/cache/dragonflyweb/main/cache/tmp",
  -- deployCommand        = "rsync -av --delete /var/cache/dragonflyweb/main/site/ $ACCESS:/var/www/static/www.dragonfly.co.nz",
  previewHost          = "0.0.0.0"
}

main :: IO ()
main = hakyllWith config $ do

    match "templates/*" $ compile templateCompiler

    match "resources/biblio/*.csl" $ compile cslCompiler
    match ("resources/biblio/*.yaml" .||. "resources/biblio/*.bib" ) $ 
        compile biblioCompiler

    match "**/*.img.md" $ compile scholmdCompiler
    match "*/**/*.md" $ compile scholmdCompiler
    match ("images/*" .||.  "google*.html" .||. "**/*.jpg" .||. "**/*.png") $ do
        route idRoute
        compile copyFileCompiler

    -- Home page
    match "pages/index.md" $ do
        route $ constRoute "index.html"
        compile $ do 
            ctx <- baseContext "index"
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/index.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- People section
    People.rules
    
    -- Blog section
    Blog.rules

    -- Publications section (not much here yet)
    match "pages/publications.md" $ do
        route $ constRoute "publications/index.html"
        compile $ do 
            ctx <- baseContext "index"
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/basic.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
    
    -- Data section (not much here yet)
    match "pages/data.md" $ do
        route $ constRoute "data/index.html"
        compile $ do 
            ctx <- baseContext "index"
            scholmdCompiler 
                >>= loadAndApplyTemplate "templates/basic.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
    
    -- Static files
    match "assets/*" $ do
        route idRoute
        compile copyFileCompiler

