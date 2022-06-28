module Pages.Room exposing (..)

import AssocList as Dict exposing (Dict)
import Domain.Card exposing (Card)
import Domain.GameState exposing (GameState(..))
import Domain.Nickname exposing (Nickname)
import Domain.PlayerId exposing (PlayerId)
import Domain.RoomName exposing (RoomName)
import Domain.Vote exposing (Vote)
import Effect
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import FeatherIcons
import Html.Attributes
import Lib.UpdateResult exposing (UpdateResult)
import Shared
import Theme.Attributes
import Theme.Card
import Theme.Colors exposing (white)
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
            { model = { model | players = addPlayer shared model.players }
            , shared = updated
            , effect =
                case updated of
                    Shared.Ready { player } ->
                        Effect.sharePlayer player

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
            , effect = Effect.shareVote vote
            }

        Reveal ->
            { model = { model | state = Chosen }
            , shared = shared
            , effect = Effect.shareState Chosen
            }

        Restart ->
            { model = { model | state = Choosing, votes = Dict.empty }
            , shared = shared
            , effect = Effect.shareState Choosing
            }


addPlayer : Shared.Model -> Dict PlayerId Nickname -> Dict PlayerId Nickname
addPlayer shared players =
    Shared.getPlayer shared
        |> Maybe.map (\player -> Dict.insert player.id player.nickname players)
        |> Maybe.withDefault players



--
-- View
--


deck : List Card
deck =
    [ "1", "TFB", "NFC" ] |> List.map Domain.Card.fromString


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
                            { label = Domain.Card.print card } |> Theme.Card.front
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
    row [ spacing 10, centerX ] <| List.map (displayCard selected shared) <| deck


displayCard : Maybe Card -> Shared.Complete -> Card -> Element Msg
displayCard selected shared card =
    if Just card == selected then
        Input.button [ moveUp 8 ]
            { onPress = Vote shared.player.id Maybe.Nothing |> Voted |> Just
            , label = Theme.Card.front { label = Domain.Card.print card }
            }

    else
        Input.button
            [ alpha <|
                if selected == Nothing then
                    1

                else
                    0.8
            ]
            { onPress = Just <| Voted <| Vote shared.player.id (Just card)
            , label = Theme.Card.front { label = Domain.Card.print card }
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
