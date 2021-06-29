{-# LANGUAGE OverloadedStrings #-}
module WebSite.SiteMap (
    root, postCtx
) where

import           Control.Monad
import           Data.Monoid          ((<>))

import           Hakyll

import           WebSite.Context

root :: String
root = "https://www.dragonfly.co.nz"

postCtx :: Context String
postCtx = constField "root" root
       <> dateField "date" "%Y-%m-%d"
       <> itemCtx
