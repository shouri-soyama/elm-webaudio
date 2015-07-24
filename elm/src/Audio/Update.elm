module Audio.Update
  ( update
  ) where

import Audio.Action as A
import Audio.Model as M

update : A.Action -> M.Model -> (M.Model, Maybe A.Task)
update action model =
  case (model, action) of
    (M.Init, A.RecordClicked) -> (M.Recording [], Just A.StartRec)
    (M.Recording sounds, A.PlayClicked) -> (M.Recorded sounds, Just (A.Play sounds))
    (M.Recording sounds, A.SoundArrived s) -> (M.Recording (sounds ++ s), Nothing) 
    _ -> (model, Nothing)
