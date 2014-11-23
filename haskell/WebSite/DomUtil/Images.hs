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
goNode (NodeContent t) = [NodeContent t]
goNode (NodeComment c) = [NodeComment c]
goNode (NodeInstruction _) = [] -- and hide processing instructions too

goElem :: Element -> Element
goElem (Element "figure" attrs children) =
    Element "figure" attrs $ concatMap goNode children ++ [xml|<figurecaption>|]
goElem (Element name attrs children) =
    -- don't know what to do, just pass it through...
    Element name attrs $ concatMap goNode children

processFigures :: String -> String
processFigures s =
    let Document prologue doc epilogue = H.parseLBS (Data.ByteString.Lazy.UTF8.fromString s)
        doc' = transform doc
        rv = renderHtml $ toHtml (Document prologue doc' epilogue)
    in rv
