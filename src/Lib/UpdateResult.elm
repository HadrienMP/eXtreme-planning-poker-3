module Lib.UpdateResult exposing (..)

import Effect exposing (Effect)
import Shared


type alias UpdateResult model =
    { model : model
    , shared : Shared.Model
    , effect : Effect
    }
