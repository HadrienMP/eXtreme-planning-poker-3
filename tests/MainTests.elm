module MainTests exposing (..)

import Effect exposing (Effect(..))
import Html.Attributes
import Main
import ProgramTest exposing (..)
import Routes exposing (Route)
import SimulatedEffect.Cmd
import SimulatedEffect.Navigation
import Test exposing (..)
import Test.Html.Selector as Selector


baseUrl : String
baseUrl =
    "https://xpp.fr"


start : Route -> ProgramTest (Main.Model ()) Main.Msg (Effect Main.Msg)
start route =
    createApplication
        { init = Main.init
        , update = Main.update
        , view = Main.view
        , onUrlChange = Main.UrlChanged
        , onUrlRequest = Main.LinkClicked
        }
        |> withSimulatedEffects simulateEffects
        -- |> ProgramTest.withSimulatedSubscriptions simulateSub
        |> withBaseUrl (baseUrl ++ Routes.toString route)
        |> ProgramTest.start ()


simulateEffects : Effect Main.Msg -> ProgramTest.SimulatedEffect Main.Msg
simulateEffects effect =
    case effect of
        None ->
            SimulatedEffect.Cmd.none

        PushUrl url ->
            SimulatedEffect.Navigation.pushUrl url

        LoadUrl url ->
            SimulatedEffect.Navigation.load url


all : Test
all =
    describe "App"
        [ describe "Home"
            [ test "Clicking on join redirects you to the room you chose" <|
                \() ->
                    start Routes.Home
                        |> fillIn "room" "Room" "dabest"
                        |> fillIn "nickname" "Nickname" "Joba"
                        |> ensureViewHas
                            [ Selector.all
                                [ Selector.id "room"
                                , Selector.attribute (Html.Attributes.value "dabest")
                                ]
                            , Selector.all
                                [ Selector.id "nickname", Selector.attribute (Html.Attributes.value "Joba") ]
                            ]
                        |> clickLink "Join" "/room/dabest"
                        |> expectPageChange (baseUrl ++ "/room/dabest")
            ]
        , describe "Room"
            [ test "the room name is displayed on the page" <|
                \() ->
                    start (Routes.Room "dabest")
                        |> expectViewHas [ Selector.text "room: dabest" ]
            , test "spaces are allowed in the room name" <|
                \() ->
                    start (Routes.Room "dabest heyhey")
                        |> expectViewHas [ Selector.text "room: dabest heyhey" ]
            ]
        ]
