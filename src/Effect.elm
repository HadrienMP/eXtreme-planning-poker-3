module Effect exposing (..)

import Browser.Navigation
import Routes exposing (Route)
import Json.Encode as Json

port vote : Json.Value -> Cmd msg


type Effect
    = None
    | PushUrl String
    | LoadUrl String


perform : Browser.Navigation.Key -> Effect -> Cmd msg
perform key effect =
    case effect of
        None ->
            Cmd.none

        PushUrl url ->
            Browser.Navigation.pushUrl key url

        LoadUrl url ->
            Browser.Navigation.load url


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
