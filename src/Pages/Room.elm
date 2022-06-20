module Pages.Room exposing (..)

import Domain.Card exposing (Card)
import Domain.Nickname
import Domain.RoomName exposing (RoomName)
import Effect
import Element exposing (..)
import Element.Border
import Element.Font
import Element.Input
import Element.Region
import FeatherIcons
import Html.Attributes
import Lib.UpdateResult exposing (UpdateResult)
import Shared
import Theme.Attributes
import Theme.Card
import Theme.Colors exposing (white)
import Theme.Input
import Theme.Theme exposing (emptySides, featherIconToElement)



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
    | Vote Card
    | Reveal


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        GotSharedMsg sharedMsg ->
            { model = model
            , shared = Shared.update sharedMsg shared
            , effect = Effect.none
            }

        Vote card ->
            { model =
                { model
                    | vote =
                        if Just card == model.vote then
                            Nothing

                        else
                            Just card
                }
            , shared = shared
            , effect = Effect.none
            }

        Reveal ->
            { model = { model | state = Chosen }
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
    Element.column [ spacing 30 ]
        [ Element.row
            [ Element.Region.heading 2, Element.Font.size 24, Theme.Attributes.id "room" ]
            [ Element.text "room: "
            , Element.el [ Element.Font.bold ] <| Element.text <| Domain.RoomName.print model.room
            ]
        , case shared of
            Shared.SettingUp setupModel ->
                Element.column [ spacing 20 ]
                    [ Shared.view setupModel |> Element.map GotSharedMsg
                    , Theme.Input.buttonWithIcon
                        { onPress = Just <| GotSharedMsg Shared.Validate
                        , icon =
                            FeatherIcons.send
                                |> featherIconToElement { shadow = False }
                        , label = "Join"
                        }
                    ]

            Shared.Ready { nickname } ->
                Element.column [ spacing 30, width fill ]
                    [ wrappedRow [ spaceEvenly, spacing 10 ]
                        [ Element.column
                            [ Element.htmlAttribute <| Html.Attributes.class "card-slot", spacing 6 ]
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
                            , Element.el [ centerX ] <| Element.text <| Domain.Nickname.print nickname
                            ]
                        , Element.Input.button [ alignTop ]
                            { onPress = Just Reveal
                            , label = Theme.Card.front { label = "Reveal" }
                            }
                        ]
                    , Element.column
                        [ Theme.Attributes.id "my-deck"
                        , Element.Border.solid
                        , Element.Border.color white
                        , Element.Border.widthEach { emptySides | top = 2 }
                        , paddingXY 0 12
                        , width fill
                        , spacing 20
                        ]
                        [ Element.text <| (++) "deck of " <| Domain.Nickname.print nickname
                        , displayDeck
                        ]
                    ]
        ]


displayDeck : Element Msg
displayDeck =
    Element.row [ spacing 10 ] <| List.map displayCard <| deck


displayCard : Card -> Element Msg
displayCard card =
    Element.Input.button []
        { onPress = Just <| Vote card
        , label = Theme.Card.front { label = Domain.Card.print card }
        }
