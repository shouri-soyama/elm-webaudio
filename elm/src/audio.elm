module Audio where

import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Signal exposing (Signal)

main : Signal Html
main = Signal.map (view address) model

type Model
  = Init
  | Recording (List (List Int))
  | Recorded (List (List Int))

type Action
  = Record
  | Play

actions : Signal.Mailbox (Maybe Action)
actions = Signal.mailbox Nothing

address : Signal.Address Action
address = Signal.forwardTo actions.address Just

model : Signal Model
model =
  Signal.foldp
    (\(Just action) model -> update action model)
    initialModel
    actions.signal

initialModel : Model
initialModel = Init

update : Action -> Model -> Model
update action model =
  case (model, action) of
    (Init, Record) -> Recording []
    (Recording sounds, Play) -> Recorded sounds
    _ -> model
 
view : Signal.Address Action -> Model -> Html
view address model =
  case model of
    Init ->
      Html.div []
      [ Html.button
        [ HA.class "btn btn-default"
        , HE.onClick address Record
        ]
        [ Html.text "Rec" ]
      ]
    Recording _ ->
      Html.div []
      [ Html.button
        [ HA.class "btn btn-default"
        , HE.onClick address Play
        ]
        [ Html.text "Play" ]
      ]
    Recorded _ ->
      Html.div [] []

port recordInit : Signal ()
port recordInit = (Signal.mailbox ()).signal
