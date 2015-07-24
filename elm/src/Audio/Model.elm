module Audio.Model
  ( Model(..)
  , init
  ) where

type Model
  = Init
  | Recording (List (List Int))
  | Recorded (List (List Int))

init : Model
init = Init
