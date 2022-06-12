module MainTests exposing (..)

import Effect exposing (Effect(..))
import Expect
import Html exposing (Html)
import Html.Attributes
import Main as Main
import ProgramTest exposing (..)
import SimulatedEffect.Cmd
import SimulatedEffect.Navigation
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


baseUrl : String
baseUrl =
    "https://xpp.fr"


start : ProgramTest (Main.Model ()) Main.Msg (Effect Main.Msg)
start =
    createApplication
        { init = Main.init
        , update = Main.update
        , view = Main.view
        , onUrlChange = Main.UrlChanged
        , onUrlRequest = Main.LinkClicked
        }
        |> withSimulatedEffects simulateEffects
        -- |> ProgramTest.withSimulatedSubscriptions simulateSub
        |> withBaseUrl baseUrl
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
            [ test "Join a room" <|
                \() ->
                    start
                        |> fillIn "room" "Room" "dabest"
                        |> fillIn "nickname" "Nickname" "Joba"
                        |> expectViewHas
                            [ Selector.all
                                [ Selector.id "room"
                                , Selector.attribute (Html.Attributes.value "dabest")
                                ]
                            , Selector.all
                                [ Selector.id "nickname"
                                , Selector.attribute (Html.Attributes.value "Joba")
                                ]
                            ]
            ]
        ]
