module TestSetup exposing (..)

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
import Ports
import ProgramTest exposing (..)
import Routes exposing (Route)
import Shared
import SimulatedEffect.Cmd
import SimulatedEffect.Navigation
import SimulatedEffect.Ports
import SimulatedEffect.Sub
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


withPlayerId : PlayerId -> ProgramTest (Main.Model ()) Main.Msg Effect -> ProgramTest (Main.Model ()) Main.Msg Effect
withPlayerId playerId test =
    simulateIncomingPort
        "playerId"
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
            SimulatedEffect.Ports.send Ports.votesOut (Vote.json vote)

        SharePlayer _ player ->
            SimulatedEffect.Ports.send Ports.playerOut (Player.json player)

        ShareState state ->
            SimulatedEffect.Ports.send Ports.statesOut (GameState.json state)


simulateSubscriptions : Main.Model () -> ProgramTest.SimulatedSub Main.Msg
simulateSubscriptions _ =
    -- TODO HMP extract a portsList
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "playerId"
            Json.Decode.value
            (Main.GotSharedMsg << Shared.GotPlayerId)
        , SimulatedEffect.Ports.subscribe Ports.playersIn
            Json.Decode.value
            (Main.GotRoomMsg << Pages.Room.GotPlayer)
        ]


writeInField : { id : String, label : String, value : String } -> ProgramTest model msg effect -> ProgramTest model msg effect
writeInField { id, label, value } programTest =
    programTest
        |> fillIn id label value
        |> ensureViewHas
            [ Selector.id id
            , Selector.attribute (Html.Attributes.value value)
            ]
