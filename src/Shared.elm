module Shared exposing (..)

import Domain.Nickname
import Domain.Player exposing (Player)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Effect exposing (Effect)
import Element exposing (Element)
import FeatherIcons
import Json.Decode
import Theme.Input
import Theme.Theme exposing (featherIconToElement)



--
-- Init
--


type alias Incomplete =
    { nickname : String
    , playerId : Maybe PlayerId
    }


type alias Complete =
    { player : Player }


type Model
    = SettingUp Incomplete
    | Ready Complete


getComplete : Model -> Maybe Complete
getComplete model =
    case model of
        SettingUp _ ->
            Nothing

        Ready complete ->
            Just complete


getPlayer : Model -> Maybe Player
getPlayer =
    getComplete >> Maybe.map .player


getPlayerId : Model -> Maybe PlayerId
getPlayerId =
    getPlayer >> Maybe.map .id


hasPlayerId : Model -> Bool
hasPlayerId model =
    case model of
        Ready _ ->
            True

        SettingUp incomplete ->
            incomplete.playerId /= Nothing


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
                    PlayerId.decode json
                        |> (\it -> SettingUp { subModel | playerId = it })

                Validate ->
                    case ( Domain.Nickname.create subModel.nickname, subModel.playerId ) of
                        ( Just nickname, Just playerId ) ->
                            Ready { player = { nickname = nickname, id = playerId } }

                        _ ->
                            model

        Ready { player } ->
            case msg of
                GotPlayerId json ->
                    PlayerId.decode json
                        |> Maybe.map (\id -> { player | id = id })
                        |> Maybe.map (\updated -> Ready { player = updated })
                        |> Maybe.withDefault model

                _ ->
                    model


noCmd : Model -> ( Model, Effect )
noCmd model =
    ( model, Effect.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    PlayerId.playerIdIn GotPlayerId


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
