module Shared exposing (..)

import Effect exposing (Effect)


type alias Model =
    { nickname : String
    }


init : Model
init =
    { nickname = "" }

