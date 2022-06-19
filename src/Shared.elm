module Shared exposing (..)

import Domain.Nickname exposing (Nickname)
import Element exposing (Element)
import FeatherIcons
import Html.Attributes
import Theme.Input



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
                    case Domain.Nickname.fromString subModel.nickname of
                        Just nickname ->
                            Ready { nickname = nickname }

                        Nothing ->
                            model

        Ready _ ->
            model


view : SetupForm -> Element Msg
view form =
    Theme.Input.textWithIcon
        { label = "Nickname"
        , onChange = UpdateNickName
        , value = form.nickname
        , icon =
            FeatherIcons.user
                |> FeatherIcons.toHtml [ Html.Attributes.style "filter" "drop-shadow(1px 1px 1px rgb(0 0 0 / 1))" ]
                |> Element.html
        }
