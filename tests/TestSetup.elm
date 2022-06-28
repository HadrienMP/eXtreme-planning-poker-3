module TestSetup exposing (..)

import Domain.Player as Player
import Domain.Vote as Vote
import Effect exposing (AtomicEffect(..), Effect(..))
import Html.Attributes
import Json.Decode
import Json.Encode
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)
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


withAPlayerId : ProgramTest (Main.Model ()) Main.Msg Effect -> ProgramTest (Main.Model ()) Main.Msg Effect
withAPlayerId test =
    test
        |> simulateIncomingPort "playerId"
            ("playerId-1234"
                |> NonEmptyString.create
                |> Maybe.map NonEmptyString.json
                |> Maybe.withDefault (Json.Encode.string "Expected withAPlayerId to produce a non empty string")
            )


withPlayerId : NonEmptyString -> ProgramTest (Main.Model ()) Main.Msg Effect -> ProgramTest (Main.Model ()) Main.Msg Effect
withPlayerId playerId test =
    simulateIncomingPort
        "playerId"
        (NonEmptyString.json playerId)
        test


simulateEffects : Effect -> ProgramTest.SimulatedEffect Main.Msg
simulateEffects effect =
    case effect of
        Atomic atomic ->
            simulateAtomicEffects atomic

        Batch effects ->
            effects |> List.map simulateAtomicEffects |> SimulatedEffect.Cmd.batch


simulateAtomicEffects : AtomicEffect -> ProgramTest.SimulatedEffect Main.Msg
simulateAtomicEffects effect =
    case effect of
        None ->
            SimulatedEffect.Cmd.none

        PushUrl url ->
            SimulatedEffect.Navigation.pushUrl url

        LoadUrl url ->
            SimulatedEffect.Navigation.load url

        ShareVote vote ->
            SimulatedEffect.Ports.send "votes" (Vote.json vote)

        SharePlayer player ->
            SimulatedEffect.Ports.send "player" (Player.json player)


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
