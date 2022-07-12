module Main exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Effect exposing (Effect)
import Element exposing (Element, centerX, centerY, column, el, fill, height, none, width)
import Lib.UpdateResult exposing (UpdateResult)
import Pages.Home
import Pages.Room
import Routes
import Shared
import Theme.Theme exposing (connectingToBack, layout, pageWidth)
import Url exposing (Url)


type alias Flags =
    ()


main : Program Flags (Model Key) Msg
main =
    Browser.application
        { init = \flags url key -> init flags url key |> Tuple.mapSecond (Effect.perform key)
        , view = view
        , update = \msg model -> update msg model |> Tuple.mapSecond (Effect.perform model.key)
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



--
-- Init
--


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
    let
        shared =
            Shared.init
    in
    ( { url = url
      , key = key
      , shared = shared
      , page = pageFrom shared url
      }
    , Effect.none
    )


pageFrom : Shared.Model -> Url -> Page
pageFrom shared url =
    case Routes.parseRoute url of
        Routes.Home ->
            Home Pages.Home.init

        Routes.Room room ->
            Room <| Pages.Room.init shared room

        Routes.NotFound ->
            NotFound



--
-- Update
--


type Msg
    = GotHomeMsg Pages.Home.Msg
    | GotRoomMsg Pages.Room.Msg
    | GotSharedMsg Shared.Msg
    | UrlChanged Url
    | LinkClicked UrlRequest


update : Msg -> Model key -> ( Model key, Effect )
update msg model =
    case ( model.page, msg ) of
        ( Home homeModel, GotHomeMsg homeMsg ) ->
            Pages.Home.update model.shared homeMsg homeModel
                |> handleUpdateResult model Home

        ( Room roomModel, GotRoomMsg roomMsg ) ->
            Pages.Room.update model.shared roomMsg roomModel
                |> handleUpdateResult model Room

        ( _, LinkClicked urlRequest ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Effect.pushUrl (Url.toString url) )

                Browser.External href ->
                    ( model, Effect.load href )

        ( _, GotSharedMsg subMsg ) ->
            ( { model | shared = Shared.update subMsg model.shared }, Effect.none )

        ( _, UrlChanged url ) ->
            ( { model | url = url, page = pageFrom model.shared url }
            , Effect.none
            )

        _ ->
            ( model, Effect.none )


handleUpdateResult : Model key -> (pageModel -> Page) -> UpdateResult pageModel -> ( Model key, Effect )
handleUpdateResult model page result =
    ( { model
        | page = page result.model
        , shared = result.shared
      }
    , result.effect
    )



--
-- Subscriptions
--


subscriptions : Model key -> Sub Msg
subscriptions model =
    Sub.batch
        [ Shared.subscriptions model.shared |> Sub.map GotSharedMsg
        , case model.page of
            Room room ->
                Pages.Room.subscriptions room |> Sub.map GotRoomMsg

            NotFound ->
                Sub.none

            Home _ ->
                Sub.none
        ]



--
-- View
--


view : Model key -> Browser.Document Msg
view model =
    { title = "App"
    , body =
        [ layout <|
            column [ width fill, height fill ]
                [ el [ pageWidth, centerX, centerY ] <| displayPage model
                , if Shared.hasPlayerId model.shared then
                    none

                  else
                    connectingToBack
                ]
        ]
    }


displayPage : Model key -> Element Msg
displayPage model =
    case model.page of
        Home homeModel ->
            Pages.Home.view model.shared homeModel
                |> Element.map GotHomeMsg

        Room roomModel ->
            Pages.Room.view model.shared roomModel
                |> Element.map GotRoomMsg

        NotFound ->
            Element.text "Not found"
