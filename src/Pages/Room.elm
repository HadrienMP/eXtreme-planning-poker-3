module Pages.Room exposing (..)

import AssocList as Dict exposing (Dict)
import Domain.Card exposing (Card)
import Domain.GameState as GameState exposing (GameState(..))
import Domain.Nickname exposing (Nickname)
import Domain.Player as Player
import Domain.PlayerId as PlayerId exposing (PlayerId)
import Domain.RoomName exposing (RoomName)
import Domain.Vote as Vote exposing (Vote)
import Effect
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import FeatherIcons
import Html.Attributes
import Json.Decode as Decode
import Lib.UpdateResult exposing (UpdateResult)
import Shared
import Theme.Attributes exposing (..)
import Theme.Card
import Theme.Colors exposing (white)
import Theme.Icons
import Theme.Input
import Theme.Theme exposing (ellipsisText, emptySides, featherIconToElement, pageWidth)



--
-- Init
--


type alias Model =
    { room : RoomName
    , state : GameState
    , votes : Dict PlayerId Card
    , players : Dict PlayerId Nickname
    }


init : Shared.Model -> RoomName -> Model
init shared room =
    { room = room
    , state = Choosing
    , votes = Dict.empty
    , players = addPlayer shared Dict.empty
    }



--
-- Update
--


type Msg
    = GotSharedMsg Shared.Msg
    | GotPlayer Decode.Value
    | GotVote Decode.Value
    | GotState Decode.Value
    | PlayerLeft Decode.Value
    | Voted Vote
    | Reveal
    | Restart
    | Join


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        GotSharedMsg sharedMsg ->
            { model = model
            , shared = Shared.update sharedMsg shared
            , effect = Effect.none
            }

        Join ->
            let
                updated =
                    Shared.update Shared.Validate shared
            in
            { model = { model | players = addPlayer updated model.players }
            , shared = updated
            , effect =
                case updated of
                    Shared.Ready { player } ->
                        Effect.sharePlayer model.room player

                    _ ->
                        Effect.none
            }

        Voted vote ->
            { model =
                case shared of
                    Shared.Ready { player } ->
                        { model | votes = Dict.update player.id (\_ -> vote.card) model.votes }

                    _ ->
                        model
            , shared = shared
            , effect = Effect.shareVote model.room vote
            }

        Reveal ->
            { model = { model | state = Chosen }
            , shared = shared
            , effect = Effect.shareState model.room Chosen
            }

        Restart ->
            { model = { model | state = Choosing, votes = Dict.empty }
            , shared = shared
            , effect = Effect.shareState model.room Choosing
            }

        GotPlayer json ->
            case Decode.decodeValue Player.decoder json of
                Ok player ->
                    { model = { model | players = Dict.insert player.id player.nickname model.players }
                    , shared = shared
                    , effect = Effect.none
                    }

                Err error ->
                    Debug.todo <| (++) "log this with a real port, " <| Decode.errorToString error

        GotVote json ->
            case Decode.decodeValue Vote.decoder json of
                Ok vote ->
                    { model = { model | votes = Dict.update vote.player (\_ -> vote.card) model.votes }
                    , shared = shared
                    , effect = Effect.none
                    }

                Err error ->
                    Debug.todo <| (++) "log this with a real port, " <| Decode.errorToString error

        GotState json ->
            case Decode.decodeValue GameState.decoder json of
                Ok state ->
                    { model =
                        { model
                            | state = state
                            , votes =
                                if state /= model.state && state == Choosing then
                                    Dict.empty

                                else
                                    model.votes
                        }
                    , shared = shared
                    , effect = Effect.none
                    }

                Err error ->
                    Debug.todo <| (++) "log this with a real port, " <| Decode.errorToString error

        PlayerLeft json ->
            case Decode.decodeValue PlayerId.decoder json of
                Ok playerId ->
                    { model = { model | players = Dict.remove playerId model.players }
                    , shared = shared
                    , effect = Effect.none
                    }

                Err error ->
                    Debug.todo <| (++) "log this with a real port, " <| Decode.errorToString error


addPlayer : Shared.Model -> Dict PlayerId Nickname -> Dict PlayerId Nickname
addPlayer shared players =
    Shared.getPlayer shared
        |> Maybe.map (\player -> Dict.insert player.id player.nickname players)
        |> Maybe.withDefault players



--
-- Subscriptions
--


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Player.playersIn GotPlayer
        , Vote.votesIn GotVote
        , GameState.statesIn GotState
        , Player.playerLeft PlayerLeft
        ]



--
-- View
--


deck : List Card
deck =
    [ "1", "TFB", "NFC" ] |> List.map Domain.Card.fromString


iconOf : Card -> Element Msg
iconOf card =
    case Domain.Card.print card of
        "1" ->
            Theme.Icons.sparkles { height = 32, color = Theme.Colors.accent }

        "TFB" ->
            Theme.Icons.elephant { height = 32, color = Theme.Colors.accent }

        "NFC" ->
            Theme.Icons.questionMark { height = 32, color = Theme.Colors.accent }

        _ ->
            Element.none


view : Shared.Model -> Model -> Element Msg
view shared model =
    case shared of
        Shared.SettingUp setupModel ->
            column [ pageWidth, spacing 30 ]
                [ title model
                , setupView setupModel
                ]

        Shared.Ready ready ->
            playingView ready model


playingView : Shared.Complete -> Model -> Element Msg
playingView shared model =
    column [ spacing 30, pageWidth ]
        [ el (Theme.Theme.bottomBorder ++ [ width fill ]) <| title model
        , wrappedRow [ spaceEvenly, spacing 10 ]
            -- (revealRestartButton model :: (model.votes |> Dict.toList |> List.map (toCardSlotData model.players) |> displayCardSlot model.state)
            (revealRestartButton model
                :: (model.players
                        |> Dict.toList
                        |> List.map (linkCard model.votes)
                        |> List.map (displayCardSlot model.state)
                   )
            )
        , displayDeck model shared
        ]


type alias CardSlotData =
    { nickname : Nickname
    , card : Maybe Card
    }


linkCard : Dict PlayerId Card -> ( PlayerId, Nickname ) -> CardSlotData
linkCard votes ( id, nickname ) =
    { nickname = nickname
    , card =
        Dict.get id votes
    }


displayCardSlot : GameState -> CardSlotData -> Element Msg
displayCardSlot state data =
    column
        [ htmlAttribute <| Html.Attributes.class "card-slot", spacing 6, width <| px 80 ]
        [ data.card
            |> Maybe.map
                (\card ->
                    case state of
                        Choosing ->
                            Theme.Card.back

                        Chosen ->
                            Theme.Card.front { label = Domain.Card.print card, icon = iconOf card }
                )
            |> Maybe.withDefault Theme.Card.slot
        , ellipsisText [ Font.center, Font.size 16 ] <|
            Domain.Nickname.print data.nickname
        ]


displayDeck : Model -> Shared.Complete -> Element Msg
displayDeck model shared =
    case model.state of
        Choosing ->
            column
                [ Theme.Attributes.id "my-deck"
                , spacing 20
                , width fill
                ]
                [ row
                    [ spacing 8
                    , width fill
                    , Border.solid
                    , Border.color white
                    , Border.widthEach { emptySides | bottom = 2 }
                    , paddingEach { emptySides | bottom = 12 }
                    ]
                    [ FeatherIcons.user |> featherIconToElement { shadow = True }
                    , ellipsisText [ clipX, Font.bold ] <| Domain.Nickname.print shared.player.nickname
                    ]
                , displayDeckCards (Dict.get shared.player.id model.votes) shared
                ]

        Chosen ->
            none


displayDeckCards : Maybe Card -> Shared.Complete -> Element Msg
displayDeckCards selected shared =
    row [ spacing 10, centerX ] <| List.indexedMap (displayCard selected shared) <| List.reverse <| deck


displayCard : Maybe Card -> Shared.Complete -> Int -> Card -> Element Msg
displayCard selected shared _ card =
    el
        [ rotate <|
            if Just card == selected then
                0.05

            else
                0.0
        , alpha <|
            if Just card == selected || selected == Nothing then
                1

            else
                0.8
        ]
    <|
        if Just card == selected then
            Input.button [ moveUp 8, class "selected" ]
                { onPress = Vote shared.player.id Maybe.Nothing |> Voted |> Just
                , label = Theme.Card.front { label = Domain.Card.print card, icon = iconOf card }
                }

        else
            Input.button
                [ scale <|
                    if selected == Nothing then
                        1

                    else
                        0.95
                ]
                { onPress = Just <| Voted <| Vote shared.player.id (Just card)
                , label = Theme.Card.front { label = Domain.Card.print card, icon = iconOf card }
                }

revealRestartButton : Model -> Element Msg
revealRestartButton model =
    Input.button [ alignTop ]
        { onPress =
            Just <|
                case model.state of
                    Choosing ->
                        Reveal

                    Chosen ->
                        Restart
        , label =
            Theme.Card.action
                { label =
                    case model.state of
                        Choosing ->
                            "Reveal"

                        Chosen ->
                            "Restart"
                , icon =
                    case model.state of
                        Choosing ->
                            Theme.Icons.eye { height = 32, color = Theme.Colors.accent }

                        Chosen ->
                            Theme.Icons.restart { height = 32, color = Theme.Colors.accent }
                }
        }


setupView : Shared.Incomplete -> Element Msg
setupView setupModel =
    column [ spacing 30, width fill ]
        [ Shared.view setupModel |> map GotSharedMsg
        , Theme.Input.buttonWithIcon
            { onPress = Just Join
            , icon =
                FeatherIcons.send
                    |> featherIconToElement { shadow = False }
            , label = "Join"
            }
        ]


title : Model -> Element Msg
title model =
    row
        [ Region.heading 2
        , Font.size 24
        , Theme.Attributes.id "room"
        , width fill
        , spacing 10
        ]
        [ FeatherIcons.box |> featherIconToElement { shadow = True }
        , text "room:"
        , ellipsisText [ Font.bold, clipX ] <| Domain.RoomName.print model.room
        ]
