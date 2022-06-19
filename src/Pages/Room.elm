module Pages.Room exposing (..)

import Domain.Card exposing (Card)
import Domain.Nickname
import Domain.RoomName exposing (RoomName)
import Effect
import Element exposing (..)
import Element.Background
import Element.Font
import Element.Input
import Element.Region
import Html.Attributes
import Lib.UpdateResult exposing (UpdateResult)
import Shared
import Theme.Attributes
import Theme.Colors exposing (white)
import Theme.Theme exposing (noTextShadow)
import FeatherIcons



--
-- Init
--


type alias Model =
    { room : RoomName
    , vote : Maybe Card
    }


init : Shared.Model -> RoomName -> Model
init _ room =
    { room = room
    , vote = Nothing
    }



--
-- Update
--


type Msg
    = GotSharedMsg Shared.Msg
    | Vote Card


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



--
-- View
--


deck : List Card
deck =
    [ "1", "TFB", "NFC" ] |> List.map Domain.Card.fromString


view : Shared.Model -> Model -> Element Msg
view shared model =
    Element.column [ spacing 20 ]
        [ Element.row
            [ Element.Region.heading 2, Element.Font.size 24, Theme.Attributes.id "room" ]
            [ Element.text "room: "
            , Element.el [ Element.Font.bold ] <| Element.text <| Domain.RoomName.print model.room
            ]
        , case shared of
            Shared.SettingUp setupModel ->
                Element.column [ spacing 20 ]
                    [ Shared.view setupModel |> Element.map GotSharedMsg
                    , Element.Input.button
                        [ Element.Background.color white
                        , Element.width fill
                        , padding 10
                        , Element.Font.color Theme.Colors.accent
                        , noTextShadow
                        ]
                        { onPress = Just <| GotSharedMsg Shared.Validate
                        , label =
                            Element.row [spacingXY 6 0, centerX]
                                [ FeatherIcons.send
                                    |> FeatherIcons.toHtml []
                                    |> Element.html
                                    |> Element.el []
                                , Element.text "Join"
                                ]
                        }
                    ]

            Shared.Ready { nickname } ->
                Element.column []
                    [ Element.column
                        [ Element.htmlAttribute <| Html.Attributes.class "card-slot" ]
                        [ Element.text <| Domain.Nickname.print nickname
                        , model.vote
                            |> Maybe.map (Element.text << Domain.Card.print)
                            |> Maybe.withDefault Element.none
                        ]
                    , Element.column [ Theme.Attributes.id "my-deck" ]
                        [ Element.text <| (++) "deck of " <| Domain.Nickname.print nickname
                        , displayDeck
                        ]
                    ]
        ]


displayDeck : Element Msg
displayDeck =
    Element.row [] <| List.map displayCard <| deck


displayCard : Card -> Element Msg
displayCard card =
    Element.Input.button []
        { onPress = Just <| Vote card
        , label = Element.text <| Domain.Card.print card
        }
