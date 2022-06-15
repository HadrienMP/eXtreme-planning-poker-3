module Shared exposing (..)

import Effect exposing (Effect)


type alias Model =
    { nickname : String
    }


init : Model
init =
    { nickname = "" }


type Msg
    = NicknameChanged String


update : Msg -> Model -> ( Model, Effect )
update msg model =
    case msg of
        NicknameChanged nickname ->
            ( { model | nickname = nickname }, Effect.none )
