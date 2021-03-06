{-# LANGUAGE TemplateHaskell #-}

module Polysemy.Trace
  ( -- * Effect
    Trace (..)

    -- * Actions
  , trace

    -- * Interpretations
  , runTraceIO
  , runIgnoringTrace
  , runTraceAsOutput
  ) where

import Polysemy
import Polysemy.Output


------------------------------------------------------------------------------
-- | An effect for logging strings.
data Trace m a where
  Trace :: String -> Trace m ()

makeSemantic ''Trace


------------------------------------------------------------------------------
-- | Run a 'Trace' effect by printing the messages to stdout.
runTraceIO :: Member (Lift IO) r => Semantic (Trace ': r) a -> Semantic r a
runTraceIO = interpret $ \case
  Trace m -> sendM $ putStrLn m
{-# INLINE runTraceIO #-}


------------------------------------------------------------------------------
-- | Run a 'Trace' effect by ignoring all of its messages.
runIgnoringTrace :: Member (Lift IO) r => Semantic (Trace ': r) a -> Semantic r a
runIgnoringTrace = interpret $ \case
  Trace _ -> pure ()
{-# INLINE runIgnoringTrace #-}


------------------------------------------------------------------------------
-- | Transform a 'Trace' effect into a 'Output' 'String' effect.
runTraceAsOutput :: Semantic (Trace ': r) a -> Semantic (Output String ': r) a
runTraceAsOutput = reinterpret $ \case
  Trace m -> output m
{-# INLINE runTraceAsOutput #-}

