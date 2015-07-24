module Audio.Task
  ( Context
  , exec
  , execJs
  ) where

import Json.Decode as JD
import Json.Encode as JE
import Result
import Task as T

import Audio.Action as A
import Audio.Model as M

type alias Context =
  { address : Signal.Address A.Action
  , js : Signal.Address JE.Value
  }

exec : Context -> A.Task -> T.Task () ()
exec context task = 
  case task of
    A.StartRec -> Signal.send context.js <| JE.object [("type", JE.string "startRec")]
    A.Play s ->
      let
        buf = JE.list <| List.map (\x -> JE.list <| List.map JE.int x) s 
      in
        Signal.send context.js <| JE.object [("type", JE.string "play"), ("buf", buf)]

execJs : Context -> JE.Value -> T.Task () ()
execJs context value =
  case JD.decodeValue jsDecoder value of
    Result.Ok sounds ->
      Signal.send context.address (A.SoundArrived sounds)
    Result.Err _ ->
      T.fail ()

jsDecoder : JD.Decoder (List (List Int))
jsDecoder = JD.list (JD.list JD.int)
