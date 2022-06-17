module TestSetup exposing (..)

import Effect exposing (Effect(..))
import Main
import ProgramTest exposing (..)
import Routes exposing (Route)
import SimulatedEffect.Cmd
import SimulatedEffect.Navigation
import Html.Attributes
import Test.Html.Selector as Selector


baseUrl : String
baseUrl =
    "http://xpp.fr"


startAppOn : Route -> ProgramTest (Main.Model ()) Main.Msg Effect
startAppOn route =
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


simulateEffects : Effect -> ProgramTest.SimulatedEffect Main.Msg
simulateEffects effect =
    case effect of
        None ->
            SimulatedEffect.Cmd.none

        PushUrl url ->
            SimulatedEffect.Navigation.pushUrl url

        LoadUrl url ->
            SimulatedEffect.Navigation.load url


writeInField : { id : String, label : String, value : String } -> ProgramTest model msg effect -> ProgramTest model msg effect
writeInField { id, label, value } programTest =
    programTest
        |> fillIn id label value
        |> ensureViewHas
            [ Selector.id id
            , Selector.attribute (Html.Attributes.value value)
            ]
