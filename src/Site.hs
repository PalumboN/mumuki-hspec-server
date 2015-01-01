{-# LANGUAGE OverloadedStrings #-}

module Site (site) where

import qualified Config
import           Data.Aeson
import           Control.Applicative
import           Snap.Core
import           Control.Monad.Trans (liftIO)
import           TestRunner
import qualified TestCompiler
import qualified Data.ByteString.Lazy.Char8 as LBS
import qualified Protocol as P

site :: Snap ()
site = method POST (
          route [ ("test", testHandler) ]) <|>
       method GET  (redirect Config.mumukiUrl)

testHandler :: Snap ()
testHandler = do
    Just request <-  decode <$> readRequestBody 102400
    result  <- liftIO . runTest . LBS.pack . compile $ request
    writeLBS . encode $ result

compile :: P.Request -> String
compile request = TestCompiler.compile (P.test request) (P.content request)