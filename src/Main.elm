module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import Element
import Pages.Home
import Pages.Room
import Routes
import Shared
import UpdateResult exposing (UpdateResult)
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


type Page
    = Home Pages.Home.Model
    | Room Pages.Room.Model
    | NotFound


type alias Model navigationKey =
    { key : navigationKey
    , url : Url
    , page : Page
    , shared : Shared.Model
    }


init : Flags -> Url -> navigationKey -> ( Model navigationKey, Effect )
init _ url key =
    ( { url = url
      , key = key
      , shared = Shared.init
      , page = pageFrom url
      }
    , Effect.none
    )


pageFrom : Url -> Page
pageFrom url =
    case Routes.parseRoute url of
        Routes.Home ->
            Home Pages.Home.init

        Routes.Room room ->
            Room <| Pages.Room.init room

        Routes.NotFound ->
            NotFound



-- Update


type Msg
    = GotHomeMsg Pages.Home.Msg
    | GotRoomMsg Pages.Room.Msg
    | UrlChanged Url
    | LinkClicked UrlRequest


update : Msg -> Model key -> ( Model key, Effect )
update msg model =
    case ( model.page, msg ) of
        ( Home homeModel, GotHomeMsg homeMsg ) ->
            Pages.Home.update model.shared homeMsg homeModel
                |> mapToModelAndEffect model Home

        ( Room roomModel, GotRoomMsg roomMsg ) ->
            Pages.Room.update model.shared roomMsg roomModel
                |> mapToModelAndEffect model Room

        ( _, LinkClicked urlRequest ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Effect.pushUrl (Url.toString url) )

                Browser.External href ->
                    ( model, Effect.load href )

        ( _, UrlChanged url ) ->
            ( { model | url = url, page = pageFrom url }
            , Effect.none
            )

        _ ->
            ( model, Effect.none )


mapToModelAndEffect : Model key -> (pageModel -> Page) -> UpdateResult pageModel -> ( Model key, Effect )
mapToModelAndEffect model page result =
    ( { model
        | page = page result.model
        , shared = result.shared
      }
    , result.effect
    )



-- View


view : Model key -> Browser.Document Msg
view model =
    { title = "App"
    , body =
        [ Element.layout [] <|
            case model.page of
                Home homeModel ->
                    Pages.Home.view model.shared homeModel
                        |> Element.map GotHomeMsg

                Room roomModel ->
                    Pages.Room.view model.shared roomModel
                        |> Element.map GotRoomMsg

                NotFound ->
                    Element.text "Not found"
        ]
    }
