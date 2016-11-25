{-# LANGUAGE OverloadedStrings #-}

module WebSite.Util (
  resultToMaybe
) where

import Data.Aeson

resultToMaybe :: Result a -> Maybe a
resultToMaybe (Success a) = Just a
resultToMaybe (Error _) = Nothing

