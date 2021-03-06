{-# LANGUAGE TemplateHaskell #-}

module Polysemy.Fixpoint
  ( -- * Effect
    Fixpoint (..)

    -- * Interpretations
  , module Polysemy.Fixpoint
  ) where

import Control.Monad.Fix
import Polysemy
import Polysemy.Internal.Fixpoint


------------------------------------------------------------------------------
-- | Run a 'Fixpoint' effect purely.
runFixpoint
    :: (∀ x. Semantic r x -> x)
    -> Semantic (Fixpoint ': r) a
    -> Semantic r a
runFixpoint lower = interpretH $ \case
  Fixpoint mf -> do
    c <- bindT mf
    pure $ fix $ lower . runFixpoint lower . c


------------------------------------------------------------------------------
-- | Run a 'Fixpoint' effect in terms of an underlying 'MonadFix' instance.
runFixpointM
    :: ( MonadFix m
       , Member (Lift m) r
       )
    => (∀ x. Semantic r x -> m x)
    -> Semantic (Fixpoint ': r) a
    -> Semantic r a
runFixpointM lower = interpretH $ \case
  Fixpoint mf -> do
    c <- bindT mf
    sendM $ mfix $ lower . runFixpointM lower . c

