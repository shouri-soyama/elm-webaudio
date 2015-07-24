module Audio.Action
  ( Action(..)
  , Task(..)
  ) where

type Action
  = RecordClicked
  | SoundArrived (List (List Int))
  | PlayClicked

type Task
  = StartRec
  | Play (List (List Int))
