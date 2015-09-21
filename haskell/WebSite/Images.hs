{-# LANGUAGE OverloadedStrings #-}
module WebSite.Images where

import           Control.Applicative (empty, (<$>))
import           Control.Monad.Except (catchError)
import           Control.Monad
import           Data.List
import           Data.Monoid (mappend, mconcat, mempty)
import           Hakyll
import           System.FilePath


--------------------------------------------------------------------------------
-- Image processing
--------------------------------------------------------------------------------

type ImageProcessing = [(String, [String])]

-- | Process image files according to a specification.
--
-- The 'Rules' and 'Context'  returned can be used to output and
imageProcessor :: Pattern -- ^ Images to process.
               -> ImageProcessing -- ^ Processing instructions.
               -> Rules ()
imageProcessor pat procs = imageRules pat procs

-- | Generate 'Rules' to process images.
imageRules :: Pattern -- ^ Pattern to identify images.
           -> ImageProcessing -- ^ Versions to generate.
           -> Rules ()
imageRules pat procs = match pat $ do
  sequence_ $ map processImage procs
  where
    imageRoute name ident = let path = toFilePath ident
                                base = takeFileName path
                                name' = name ++ "-" ++ base
                            in replaceFileName path name'
    -- Process an image with no instructions.
    processImage (name, []) = version name $ do
        route $ customRoute (imageRoute name)
        compile $ copyFileCompiler
    -- Process with scale and crop instructions.
    processImage (name, args) = version name $ do
        let cmd = "convert"
            args' = ["-"] ++ args ++ ["-"]
        route $ customRoute (imageRoute name)
        compile $ getResourceLBS >>= withItemBody (unixFilterLBS cmd args')


