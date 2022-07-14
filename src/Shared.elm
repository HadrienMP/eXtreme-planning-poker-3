port module Shared exposing (Incomplete, Model, Msg(..), getIncomplete, getPlayer, getPlayerId, init, match, subscriptions, update, view)

import Domain.Nickname
import Domain.Player exposing (Player)
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Element exposing (Element)
import FeatherIcons
import Json.Decode
import Theme.Input
import Theme.Theme exposing (featherIconToElement)


port disconnected : (Json.Decode.Value -> msg) -> Sub msg



--
-- Model
--


type alias Incomplete =
    { nickname : String
    , playerId : Maybe PlayerId
    }


type Readyness
    = Ready Player
    | NotReady Incomplete


type alias Model =
    { readyness : Readyness
    , connected : Bool
    }


match : Model -> (Incomplete -> a) -> (Player -> a) -> a
match model f g =
    case model.readyness of
        Ready player ->
            g player

        NotReady incomplete ->
            f incomplete


getIncomplete : Model -> Maybe Incomplete
getIncomplete model =
    case model.readyness of
        Ready _ ->
            Nothing

        NotReady incomplete ->
            Just incomplete


getPlayer : Model -> Maybe Player
getPlayer model =
    case model.readyness of
        Ready player ->
            Just player

        _ ->
            Nothing


getPlayerId : Model -> Maybe PlayerId
getPlayerId =
    getPlayer >> Maybe.map .id



--
-- Init
--


init : Model
init =
    { readyness = NotReady { nickname = "", playerId = Nothing }, connected = False }



--
-- Update
--


type Msg
    = UpdateNickName String
    | GotPlayerId Json.Decode.Value
    | GotDisconnected Json.Decode.Value
    | Validate


update : Msg -> Model -> Model
update msg model =
    case model.readyness of
        NotReady subModel ->
            case msg of
                UpdateNickName nickname ->
                    { model | readyness = NotReady { subModel | nickname = nickname } }

                GotPlayerId json ->
                    PlayerId.decode json
                        |> (\it -> { model | readyness = NotReady { subModel | playerId = it }, connected = True })

                Validate ->
                    case ( Domain.Nickname.create subModel.nickname, subModel.playerId ) of
                        ( Just nickname, Just playerId ) ->
                            { model | readyness = Ready { nickname = nickname, id = playerId } }

                        _ ->
                            model

                GotDisconnected _ ->
                    { model | connected = False }

        Ready player ->
            case msg of
                GotPlayerId json ->
                    PlayerId.decode json
                        |> Maybe.map (\id -> { player | id = id })
                        |> Maybe.map Ready
                        |> Maybe.map (\jojo -> { model | readyness = jojo, connected = True })
                        |> Maybe.withDefault model

                GotDisconnected _ ->
                    { model | connected = False }

                _ ->
                    model



--
-- Subscriptions
--


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ PlayerId.playerIdIn GotPlayerId
        , disconnected GotDisconnected
        ]



--
-- View
--


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
