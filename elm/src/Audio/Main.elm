module Audio.Main
  ( main
  ) where

import Html
import Json.Encode as JE
import Task

import Audio.Action as A
import Audio.Model as M
import Audio.Task as T
import Audio.Update as U
import Audio.View as V
import Lib.App as App

app : App.App A.Action A.Task
app = App.create
  { model = M.init
  , update = U.update
  , view = V.view
  }

main : Signal Html.Html
main = app.main

toJs : Signal.Mailbox JE.Value
toJs = Signal.mailbox JE.null

taskContext : T.Context
taskContext =
  { address = app.address
  , js = toJs.address
  }

port toElm : Signal JE.Value

port fromElm : Signal JE.Value
port fromElm = toJs.signal

port execTask : Signal (Task.Task () ())
port execTask = Signal.mergeMany
  [ App.execTask (T.exec taskContext) app.task
  , Signal.map (T.execJs taskContext) toElm
  ]
