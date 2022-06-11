module MainTests exposing (..)

import Effect exposing (Effect(..))
import Expect
import Main as Main
import ProgramTest exposing (..)
import SimulatedEffect.Cmd
import SimulatedEffect.Navigation
import Test exposing (..)


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
                        |> expectBrowserUrl (Expect.equal <| baseUrl ++ "/")
            ]
        ]
