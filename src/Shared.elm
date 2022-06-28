port module Shared exposing (..)

import Domain.Nickname
import Domain.Player exposing (Player)
import Element exposing (Element)
import FeatherIcons
import Json.Decode
import Lib.NonEmptyString as NonEmptyString exposing (NonEmptyString)
import Theme.Input
import Theme.Theme exposing (featherIconToElement)


port playerIdPort : (Json.Decode.Value -> msg) -> Sub msg



--
-- Init
--


type alias Incomplete =
    { nickname : String
    , playerId : Maybe NonEmptyString
    }


type alias Complete =
    { player : Player }


type Model
    = SettingUp Incomplete
    | Ready Complete


hasPlayerId : Model -> Bool
hasPlayerId model =
    case model of
        SettingUp incomplete ->
            incomplete.playerId /= Nothing

        Ready _ ->
            True


init : Model
init =
    SettingUp { nickname = "", playerId = Nothing }



--
-- Update
--


type Msg
    = UpdateNickName String
    | GotPlayerId Json.Decode.Value
    | Validate


update : Msg -> Model -> Model
update msg model =
    case model of
        SettingUp subModel ->
            case msg of
                UpdateNickName nickname ->
                    SettingUp { subModel | nickname = nickname }

                GotPlayerId json ->
                    json
                        |> Json.Decode.decodeValue NonEmptyString.decoder
                        |> Result.toMaybe
                        |> (\it -> SettingUp { subModel | playerId = it })

                -- TODO HMP do something with the error
                Validate ->
                    -- TODO HMP do some error handling here, maybe display a help message
                    case ( Domain.Nickname.fromString subModel.nickname, subModel.playerId ) of
                        ( Just nickname, Just playerId ) ->
                            Ready { player = { nickname = nickname, id = playerId } }

                        _ ->
                            model

        Ready _ ->
            model


subscriptions : Model -> Sub Msg
subscriptions _ =
    playerIdPort GotPlayerId


view : Incomplete -> Element Msg
view form =
    Theme.Input.textWithIcon
        { label = "Nickname"
        , onChange = UpdateNickName
        , value = form.nickname
        , icon =
            FeatherIcons.user
                |> featherIconToElement { shadow = True }
        , size = Just 10
        }
