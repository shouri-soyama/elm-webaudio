module Audio where

import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Signal exposing (Signal)
import Task as T

main : Signal Html
main = Signal.map (view address) model

type Model
  = Init
  | Recording (List (List Int))
  | Recorded (List (List Int))

type Action
  = RecordClicked
  | SoundArrived (List (List Int))
  | PlayClicked

type Task
  = StartRec
  | Play (List (List Int))

actions : Signal.Mailbox (Maybe Action)
actions = Signal.mailbox Nothing

address : Signal.Address Action
address = Signal.forwardTo actions.address Just

modelWithTask : Signal (Model, Maybe Task)
modelWithTask =
  Signal.foldp
    (\(Just action) (model, task) -> update action model)
    (Init, Nothing)
    actions.signal

model : Signal Model
model = Signal.map fst modelWithTask

execTask : Signal (T.Task () ())
execTask = Signal.filterMap (Maybe.map exec << snd) (T.succeed ()) modelWithTask

exec : Task -> T.Task () ()
exec task =
  case task of
    StartRec -> Signal.send startRecM.address (Just ())
    Play s -> Signal.send playAudioM.address (Just s)

update : Action -> Model -> (Model, Maybe Task)
update action model =
  case (model, action) of
    (Init, RecordClicked) -> (Recording [], Just StartRec)
    (Recording sounds, PlayClicked) -> (Recorded sounds, Just (Play sounds))
    (Recording sounds, SoundArrived s) -> (Recording (sounds ++ s), Nothing) 
    _ -> (model, Nothing)
 
view : Signal.Address Action -> Model -> Html
view address model =
  case model of
    Init ->
      Html.div []
      [ Html.button
        [ HA.class "btn btn-default"
        , HE.onClick address RecordClicked
        ]
        [ Html.text "Rec" ]
      ]
    Recording _ ->
      Html.div []
      [ Html.button
        [ HA.class "btn btn-default"
        , HE.onClick address PlayClicked
        ]
        [ Html.text "Play" ]
      ]
    Recorded _ ->
      Html.div [] []

startRecM : Signal.Mailbox (Maybe ())
startRecM = Signal.mailbox Nothing

port startRec : Signal (Maybe ())
port startRec = startRecM.signal

playAudioM : Signal.Mailbox (Maybe (List (List Int)))
playAudioM = Signal.mailbox Nothing

port soundEncoded : Signal (List (List Int))

port playAudio : Signal (Maybe (List (List Int)))
port playAudio = playAudioM.signal

port soundArrived : Signal (T.Task () ())
port soundArrived =
  Signal.map (\x -> Signal.send address (SoundArrived x)) soundEncoded

port taskRunner : Signal (T.Task () ())
port taskRunner = execTask
