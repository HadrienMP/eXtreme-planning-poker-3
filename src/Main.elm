module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import Element
import Element.Input
import Html.Attributes
import Url exposing (Url)


type alias Flags =
    ()


main : Program Flags (Model Key) Msg
main =
    Browser.application
        { init = \flags url key -> init flags url key |> Tuple.mapSecond (Effect.perform key)
        , view = view
        , update = \msg model -> update msg model |> Tuple.mapSecond (Effect.perform model.key)
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- Init


type alias Model navigationKey =
    { nickname : String
    , room : String
    , key : navigationKey
    , url : Url
    }


init : Flags -> Url -> navigationKey -> ( Model navigationKey, Effect Msg )
init _ url key =
    ( { nickname = ""
      , room = ""
      , url = url
      , key = key
      }
    , Effect.none
    )



-- Update


type Msg
    = NicknameChanged String
    | RoomNameChanged String
    | UrlChanged Url
    | LinkClicked UrlRequest


update : Msg -> Model key -> ( Model key, Effect Msg )
update msg model =
    case msg of
        NicknameChanged nick ->
            ( { model | nickname = nick }, Effect.none )

        RoomNameChanged room ->
            ( { model | room = room }, Effect.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Effect.pushUrl (Url.toString url) )

                Browser.External href ->
                    ( model, Effect.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Effect.none
            )



-- View


view : Model key -> Browser.Document Msg
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
                , Element.Input.text [ Element.htmlAttribute <| Html.Attributes.id "room" ]
                    { onChange = RoomNameChanged
                    , text = model.room
                    , label = Element.Input.labelHidden "Room"
                    , placeholder = Nothing
                    }
                ]
        ]
    }
