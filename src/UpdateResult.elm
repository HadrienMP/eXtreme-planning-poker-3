module UpdateResult exposing (..)
import Shared
import Effect exposing (Effect)

type alias UpdateResult model =
    { model : model
    , shared : Shared.Model
    , effect: Effect
    }
