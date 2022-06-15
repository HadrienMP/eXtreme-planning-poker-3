module Effect exposing (..)

import Browser.Navigation


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


load : String -> Effect
load =
    LoadUrl
