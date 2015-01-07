{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module WebSite.DomUtil.Images (
    processFigures
) where

import qualified Data.ByteString.Lazy.UTF8       (fromString)
import qualified Data.Map                        as M
import           Data.Text.Lazy                  hiding (concatMap)
import           Text.Blaze.Html                 (toHtml)
import           Text.Blaze.Html.Renderer.String (renderHtml)
import           Text.Hamlet.XML
import           Text.HTML.DOM                   as H
import           Text.XML


main :: IO()
main = interact processFigures

transform :: Element -> Element
transform (Element _name attrs children) = Element "html" M.empty
    [xml|
            $forall child <- children
                ^{goNode child}
    |]

goNode :: Node -> [Node]
goNode (NodeElement e) = [NodeElement $ goElem e]
goNode a = [a]

goElem :: Element -> Element
goElem (Element "figure" attrs children) =
    Element "figure" attrs $ concatMap goNode children ++ [xml|<figcaption>|]
    -- need a check here to make sure that we don't append a figcaption if one already exists ...
    -- exact form of this will depend on how meta data is handled
goElem (Element name attrs children) =
    -- don't know what to do, just pass it through...
    Element name attrs $ concatMap goNode children

processFigures :: String -> String
processFigures s =
    let Document prologue doc epilogue = H.parseLBS (Data.ByteString.Lazy.UTF8.fromString s)
        doc' = transform doc
        rv = renderHtml $ toHtml (Document prologue doc' epilogue)
    in rv
