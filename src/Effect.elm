module Effect exposing (..)

import Browser.Navigation
import Domain.GameState as GameState exposing (GameState, statesOut)
import Domain.Player as Player exposing (Player, playerOut)
import Domain.Vote as Vote exposing (Vote, votesOut)
import Routes exposing (Route)


type AtomicEffect
    = None
    | PushUrl String
    | LoadUrl String
    | ShareVote Vote
    | SharePlayer Player
    | ShareState GameState


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

        ShareVote vote ->
            vote |> Vote.json |> votesOut

        SharePlayer toShare ->
            toShare |> Player.json |> playerOut

        ShareState toShare ->
            toShare |> GameState.json |> statesOut


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


sharePlayer : Player -> Effect
sharePlayer =
    Atomic << SharePlayer


shareVote : Vote -> Effect
shareVote =
    Atomic << ShareVote


shareState : GameState -> Effect
shareState =
    Atomic << ShareState



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
