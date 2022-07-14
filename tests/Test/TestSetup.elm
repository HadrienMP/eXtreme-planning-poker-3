module Test.TestSetup exposing (..)

import Domain.GameState as GameState
import Domain.Player as Player
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Domain.Vote as Vote
import Effect exposing (AtomicEffect(..), Effect(..))
import Html.Attributes
import Json.Decode
import Json.Encode
import Lib.NonEmptyString as NonEmptyString
import Main
import Pages.Room
import ProgramTest exposing (..)
import Routes exposing (Route)
import Shared
import SimulatedEffect.Cmd
import SimulatedEffect.Navigation
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test.Html.Selector as Selector
import Test.Ports


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
        |> simulateIncomingPort Test.Ports.playerIdIn
            ("playerId-1234"
                |> NonEmptyString.create
                |> Maybe.map NonEmptyString.json
                |> Maybe.withDefault (Json.Encode.string "Expected withAPlayerId to produce a non empty string")
            )


withPlayerId : PlayerId -> ProgramTest (Main.Model ()) Main.Msg Effect -> ProgramTest (Main.Model ()) Main.Msg Effect
withPlayerId playerId test =
    simulateIncomingPort
        Test.Ports.playerIdIn
        (PlayerId.json playerId)
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

        ShareVote _ vote ->
            SimulatedEffect.Ports.send Test.Ports.votesOut (Vote.json vote)

        SharePlayer _ player ->
            SimulatedEffect.Ports.send Test.Ports.playerOut (Player.json player)

        ShareState _ state ->
            SimulatedEffect.Ports.send Test.Ports.statesOut (GameState.json state)

        Log _ ->
            SimulatedEffect.Cmd.none

        Warn _ ->
            SimulatedEffect.Cmd.none

        Error _ ->
            SimulatedEffect.Cmd.none


simulateSubscriptions : Main.Model () -> ProgramTest.SimulatedSub Main.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe Test.Ports.playerIdIn
            Json.Decode.value
            (Main.GotSharedMsg << Shared.GotPlayerId)
        , SimulatedEffect.Ports.subscribe Test.Ports.playerIdIn
            Json.Decode.value
            (Main.GotRoomMsg << Pages.Room.GotPlayerId)
        , SimulatedEffect.Ports.subscribe Test.Ports.playersIn
            Json.Decode.value
            (Main.GotRoomMsg << Pages.Room.GotPlayer)
        , SimulatedEffect.Ports.subscribe Test.Ports.votesIn
            Json.Decode.value
            (Main.GotRoomMsg << Pages.Room.GotVote)
        , SimulatedEffect.Ports.subscribe Test.Ports.statesIn
            Json.Decode.value
            (Main.GotRoomMsg << Pages.Room.GotState)
        , SimulatedEffect.Ports.subscribe Test.Ports.playerLeft
            Json.Decode.value
            (Main.GotRoomMsg << Pages.Room.PlayerLeft)
        ]


writeInField : { id : String, label : String, value : String } -> ProgramTest model msg effect -> ProgramTest model msg effect
writeInField { id, label, value } programTest =
    programTest
        |> fillIn id label value
        |> ensureViewHas
            [ Selector.id id
            , Selector.attribute (Html.Attributes.value value)
            ]
