module Shared exposing (..)

import Element exposing (Element)
import Theme.Input
import Nickname exposing (Nickname)



--
-- Init
--


type alias SetupForm =
    { nickname : String
    }


type Model
    = SettingUp SetupForm
    | Ready { nickname : Nickname }


init : Model
init =
    SettingUp { nickname = "" }



--
-- Update
--


type Msg
    = UpdateNickName String
    | Validate


update : Msg -> Model -> Model
update msg model =
    case model of
        SettingUp subModel ->
            case msg of
                UpdateNickName nickname ->
                    SettingUp { nickname = nickname }

                Validate ->
                    case Nickname.fromString subModel.nickname of
                        Just nickname ->
                            Ready { nickname = nickname }

                        Nothing ->
                            model

        Ready _ ->
            model


view : SetupForm -> Element Msg
view form =
    Theme.Input.text
        { label = "Nickname"
        , onChange = UpdateNickName
        , value = form.nickname
        }
