{-# LANGUAGE OverloadedStrings #-}
module WebSite.Context (
  baseContext,
) where

import Data.Monoid ((<>))
import System.FilePath (takeBaseName)

import Hakyll

baseContext :: String -> Compiler (Context String)
baseContext section = do
    path <- fmap toFilePath getUnderlying
    return $  dateField  "date"   "%B %e, %Y"
           <> constField "jquery" "//ajax.googleapis.com/ajax/libs/jquery/2.0.3"
           <> constField "section" section
           <> constField ("on-" ++ takeBaseName path) ""
           <> defaultContext

