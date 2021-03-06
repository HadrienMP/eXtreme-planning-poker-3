module Effect exposing (..)

import Browser.Navigation
import Console
import Domain.GameState as GameState exposing (GameState)
import Domain.Player as Player exposing (Player)
import Domain.RoomName exposing (RoomName)
import Domain.Vote as Vote exposing (Vote)
import Routes exposing (Route)


type AtomicEffect
    = None
    | PushUrl String
    | LoadUrl String
    | ShareVote RoomName Vote
    | SharePlayer RoomName Player
    | ShareState RoomName GameState
    | Log String
    | Error String
    | Warn String


type Effect
    = Atomic AtomicEffect
    | Batch (List AtomicEffect)


perform : Browser.Navigation.Key -> Effect -> Cmd msg
perform key effect =
    case effect of
        Atomic atomic ->
            performAtomic key atomic

        Batch effects ->
            effects
                |> List.map (performAtomic key)
                |> Cmd.batch


performAtomic : Browser.Navigation.Key -> AtomicEffect -> Cmd msg
performAtomic key effect =
    case effect of
        None ->
            Cmd.none

        PushUrl url ->
            Browser.Navigation.pushUrl key url

        LoadUrl url ->
            Browser.Navigation.load url

        ShareVote room vote ->
            Vote.sendOut room vote

        SharePlayer room player ->
            Player.sendOut room player

        ShareState room state ->
            GameState.sendOut room state

        Log msg ->
            Console.log msg

        Error msg ->
            Console.error msg

        Warn msg ->
            Console.warn msg


none : Effect
none =
    Atomic None


batch : List Effect -> Effect
batch effects =
    effects
        |> toAtomicList []
        |> Batch


toAtomicList : List AtomicEffect -> List Effect -> List AtomicEffect
toAtomicList acc effects =
    case effects of
        [] ->
            acc

        head :: tail ->
            case head of
                Atomic atomic ->
                    toAtomicList (atomic :: acc) tail

                Batch list ->
                    toAtomicList (list ++ acc) tail


sharePlayer : RoomName -> Player -> Effect
sharePlayer room =
    Atomic << SharePlayer room


shareVote : RoomName -> Vote -> Effect
shareVote room =
    Atomic << ShareVote room


shareState : RoomName -> GameState -> Effect
shareState room =
    Atomic << ShareState room



-- Navigation


pushUrl : String -> Effect
pushUrl =
    Atomic << PushUrl


pushRoute : Route -> Effect
pushRoute route =
    Atomic <| PushUrl <| Routes.toString route


load : String -> Effect
load =
    Atomic << LoadUrl


loadRoute : Route -> Effect
loadRoute route =
    Atomic <| LoadUrl <| Routes.toString route



-- Console


error : String -> Effect
error =
    Atomic << Error


warn : String -> Effect
warn =
    Atomic << Warn


log : String -> Effect
log =
    Atomic << Log
