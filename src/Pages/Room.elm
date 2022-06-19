module Pages.Room exposing (..)

import Domain.Card exposing (Card)
import Domain.Nickname
import Domain.RoomName exposing (RoomName)
import Effect
import Element exposing (..)
import Element.Input
import Html.Attributes
import Lib.UpdateResult exposing (UpdateResult)
import Shared



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
    case shared of
        Shared.SettingUp setupModel ->
            Element.column []
                [ Element.text <| "room: " ++ Domain.RoomName.print model.room
                , Shared.view setupModel |> Element.map GotSharedMsg
                , Element.Input.button []
                    { onPress = Just <| GotSharedMsg Shared.Validate
                    , label = Element.text "Join"
                    }
                ]

        Shared.Ready { nickname } ->
            Element.column []
                [ Element.text <| "room: " ++ Domain.RoomName.print model.room
                , Element.column
                    [ Element.htmlAttribute <| Html.Attributes.class "card-slot" ]
                    [ Element.text <| Domain.Nickname.print nickname
                    , model.vote
                        |> Maybe.map (Element.text << Domain.Card.print)
                        |> Maybe.withDefault Element.none
                    ]
                , Element.column [ Element.htmlAttribute <| Html.Attributes.id "my-deck" ]
                    [ Element.text <| (++) "deck of " <| Domain.Nickname.print nickname
                    , displayDeck
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
