module Audio.View
  ( view
  ) where

import Audio.Action as A
import Audio.Model as M
import Html
import Html.Attributes as HA
import Html.Events as HE

view : Signal.Address A.Action -> M.Model -> Html.Html
view address model =
  case model of
    M.Init ->
      Html.div []
      [ Html.button
        [ HA.class "btn btn-default"
        , HE.onClick address A.RecordClicked
        ]
        [ Html.text "Rec" ]
      ]
    M.Recording _ ->
      Html.div []
      [ Html.button
        [ HA.class "btn btn-default"
        , HE.onClick address A.PlayClicked
        ]
        [ Html.text "Play" ]
      ]
    M.Recorded _ ->
      Html.div [] []

