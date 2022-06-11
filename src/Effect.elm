module Effect exposing (..)

import Browser.Navigation


type Effect msg
    = None
    | PushUrl String
    | LoadUrl String


perform : Browser.Navigation.Key -> Effect msg -> Cmd msg
perform key effect =
    case effect of
        None ->
            Cmd.none

        PushUrl url ->
            Browser.Navigation.pushUrl key url

        LoadUrl url ->
            Browser.Navigation.load url


none : Effect msg
none =
    None



-- Navigation


pushUrl : String -> Effect msg
pushUrl =
    PushUrl


load : String -> Effect msg
load =
    LoadUrl
