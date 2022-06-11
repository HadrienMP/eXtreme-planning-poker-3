module Main exposing (..)

import Browser
import Element
import Element.Input
import Html.Attributes


type Msg
    = NicknameChanged String


type alias Model =
    { nickname : String
    }


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { nickname = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NicknameChanged nick ->
            ( { model | nickname = nick }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "App"
    , body =
        [ Element.layout [] <|
            Element.column []
                [ if model.nickname /= "" then
                    Element.text <| "Welcome " ++ model.nickname

                  else
                    Element.none
                , Element.Input.text [ Element.htmlAttribute <| Html.Attributes.id "nickname" ]
                    { onChange = NicknameChanged
                    , text = model.nickname
                    , label = Element.Input.labelHidden "Nickname"
                    , placeholder = Nothing
                    }
                ]
        ]
    }
