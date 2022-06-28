module Pages.Room exposing (..)

import Domain.Card exposing (Card)
import Domain.Nickname exposing (Nickname)
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


type State
    = Choosing
    | Chosen


type alias Model =
    { room : RoomName
    , vote : Maybe Card
    , state : State
    }


init : Shared.Model -> RoomName -> Model
init _ room =
    { room = room
    , vote = Nothing
    , state = Choosing
    }



--
-- Update
--


type Msg
    = GotSharedMsg Shared.Msg
    | Voted Vote
    | Reveal
    | Restart


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        GotSharedMsg sharedMsg ->
            { model = model
            , shared = Shared.update sharedMsg shared
            , effect = Effect.none
            }

        Voted vote ->
            { model =
                { model
                    | vote =
                        if Just vote.card == model.vote then
                            Nothing

                        else
                            Just vote.card
                }
            , shared = shared
            , effect = Effect.ShareVote vote
            }

        Reveal ->
            { model = { model | state = Chosen }
            , shared = shared
            , effect = Effect.none
            }

        Restart ->
            { model = { model | state = Choosing, vote = Nothing }
            , shared = shared
            , effect = Effect.none
            }



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
            [ displayCardSlot model shared.nickname
            , revealRestartButton model
            ]
        , displayDeck model shared
        ]


displayCardSlot : Model -> Nickname -> Element Msg
displayCardSlot model nickname =
    column
        [ htmlAttribute <| Html.Attributes.class "card-slot", spacing 6, width <| px 80 ]
        [ model.vote
            |> Maybe.map
                (\card ->
                    case model.state of
                        Choosing ->
                            Theme.Card.back

                        Chosen ->
                            { label = Domain.Card.print card } |> Theme.Card.front
                )
            |> Maybe.withDefault Theme.Card.slot
        , ellipsisText [ Font.center, Font.size 16 ] <|
            Domain.Nickname.print nickname
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
                    , ellipsisText [ clipX, Font.bold ] <| Domain.Nickname.print shared.nickname
                    ]
                , displayDeckCards model.vote shared
                ]

        Chosen ->
            none


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
            { onPress = Just <| GotSharedMsg Shared.Validate
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


displayDeckCards : Maybe Card -> Shared.Complete -> Element Msg
displayDeckCards selected shared =
    row [ spacing 10, centerX ] <| List.map (displayCard selected shared) <| deck


displayCard : Maybe Card -> Shared.Complete -> Card -> Element Msg
displayCard selected shared card =
    Input.button
        [ moveUp <|
            if Just card == selected then
                8

            else
                0
        , alpha <|
            if Just card == selected || selected == Nothing then
                1

            else
                0.8
        ]
        { onPress = Just <| Voted <| Vote shared.playerId card
        , label = Theme.Card.front { label = Domain.Card.print card }
        }
