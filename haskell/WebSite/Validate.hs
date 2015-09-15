module WebSite.Validate (
  validatePage
  )
       where

import           Hakyll

import           Control.Monad.Except
import           Data.List
import           Data.Tree.NTree.TypeDefs
import           Text.XML.HXT.DOM.TypeDefs
import           Text.XML.HXT.Parser.HtmlParsec

validatePage :: Item String -> Compiler (Item String)
validatePage item = do
  return $ fmap htmlValidation item

-- TODO: Workout out how to unpack XError from NTree XNode
getErrors :: NTree XNode -> Bool
--getErrors (NTree (XError _ _)) = True
getErrors _ = False

htmlValidation :: String -> String
htmlValidation html =
  let doc = parseHtmlContent html
      d = filter getErrors doc
  in if length d == 0
     then html
     else error "Bad xml" -- TODO: return a decent error message
