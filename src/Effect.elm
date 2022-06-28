port module Effect exposing (..)

import Browser.Navigation
import Domain.Player as Player exposing (Player)
import Domain.Vote as Vote exposing (Vote)
import Json.Encode as Json
import Routes exposing (Route)


port votes : Json.Value -> Cmd msg


port player : Json.Value -> Cmd msg


type AtomicEffect
    = None
    | PushUrl String
    | LoadUrl String
    | ShareVote Vote
    | SharePlayer Player


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
            vote |> Vote.json |> votes

        SharePlayer toShare ->
            toShare |> Player.json |> player


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
