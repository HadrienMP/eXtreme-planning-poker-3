port module Effect exposing (..)

import Browser.Navigation
import Domain.Vote as Vote exposing (Vote)
import Json.Encode as Json
import Routes exposing (Route)


port votes : Json.Value -> Cmd msg


type Effect
    = None
    | PushUrl String
    | LoadUrl String
    | ShareVote Vote


perform : Browser.Navigation.Key -> Effect -> Cmd msg
perform key effect =
    case effect of
        None ->
            Cmd.none

        PushUrl url ->
            Browser.Navigation.pushUrl key url

        LoadUrl url ->
            Browser.Navigation.load url

        ShareVote vote ->
            vote |> Vote.json |> votes


none : Effect
none =
    None



-- Navigation


pushUrl : String -> Effect
pushUrl =
    PushUrl


pushRoute : Route -> Effect
pushRoute route =
    PushUrl <| Routes.toString route


load : String -> Effect
load =
    LoadUrl


loadRoute : Route -> Effect
loadRoute route =
    LoadUrl <| Routes.toString route
