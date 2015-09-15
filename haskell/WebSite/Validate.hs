module WebSite.Validate (
  validatePage
  )
       where

import           Hakyll

import           Control.Monad.Except
import           Data.List
import           Text.HTML.TagSoup
--import           Text.XML.HXT.Core
--import           Text.XML.HXT.DOM.FormatXmlTree
import           Text.XML.HXT.DOM.ShowXml
import           Text.XML.HXT.Parser.HtmlParsec

validatePage :: Item String -> Compiler (Item String)
validatePage item = do
  return $ fmap htmlValidation item

htmlValidation :: String -> String
htmlValidation html =
  let doc = parseHtmlContent html
  in xshow doc

htmlValidatios = unlines . g . f . parseTagsOptions opts
    where
        opts = parseOptions{optTagPosition=True, optTagWarning=True}

        f :: [Tag String] -> [String]
        f (TagPosition row col:TagWarning warn:rest) =
            ("Warning (" ++ show row ++ "," ++ show col ++ "): " ++ warn) : f rest
        f (TagWarning warn:rest) =
            ("Warning (?,?): " ++ warn) : f rest
        f (_:rest) = f rest
        f [] = []

        g xs = xs ++ [if n == 0 then "Success, no warnings"
                      else "Failed, " ++ show n ++ " warning" ++ ['s'|n>1]]
            where n = length xs
