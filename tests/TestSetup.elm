module TestSetup exposing (..)

import Effect exposing (Effect(..))
import Html.Attributes
import Json.Decode
import Json.Encode
import Lib.NonEmptyString as NonEmptyString
import Main
import ProgramTest exposing (..)
import Routes exposing (Route)
import Shared
import SimulatedEffect.Cmd
import SimulatedEffect.Navigation
import SimulatedEffect.Ports
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
        |> withSimulatedSubscriptions simulateSubscriptions
        |> withBaseUrl (baseUrl ++ Routes.toString route)
        |> start ()


withPlayerId : ProgramTest (Main.Model ()) Main.Msg Effect -> ProgramTest (Main.Model ()) Main.Msg Effect
withPlayerId test =
    test
        |> simulateIncomingPort "playerId" ("playerId-1234" |> NonEmptyString.create |> Maybe.map NonEmptyString.json |> Maybe.withDefault (Json.Encode.string "wut"))


simulateEffects : Effect -> ProgramTest.SimulatedEffect Main.Msg
simulateEffects effect =
    case effect of
        None ->
            SimulatedEffect.Cmd.none

        PushUrl url ->
            SimulatedEffect.Navigation.pushUrl url

        LoadUrl url ->
            SimulatedEffect.Navigation.load url


simulateSubscriptions : Main.Model () -> ProgramTest.SimulatedSub Main.Msg
simulateSubscriptions _ =
    -- TODO HMP extract a portsList
    SimulatedEffect.Ports.subscribe "playerId"
        Json.Decode.value
        (Main.GotSharedMsg << Shared.GotPlayerId)


writeInField : { id : String, label : String, value : String } -> ProgramTest model msg effect -> ProgramTest model msg effect
writeInField { id, label, value } programTest =
    programTest
        |> fillIn id label value
        |> ensureViewHas
            [ Selector.id id
            , Selector.attribute (Html.Attributes.value value)
            ]
