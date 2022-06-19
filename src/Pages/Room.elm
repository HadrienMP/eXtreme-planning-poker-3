module Pages.Room exposing (..)

import Effect
import Element exposing (..)
import Element.Input
import Html.Attributes
import Nickname
import RoomName exposing (RoomName)
import Shared
import UpdateResult exposing (UpdateResult)



--
-- Init
--


type alias Model =
    { room : RoomName
    , vote : Maybe String
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
    | Vote String


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
                        case model.vote of
                            Just c ->
                                if c == card then
                                    Nothing

                                else
                                    Just card

                            Nothing ->
                                Just card
                }
            , shared = shared
            , effect = Effect.none
            }



--
-- View
--


deck : List String
deck =
    [ "1", "TFB", "NFC" ]


view : Shared.Model -> Model -> Element Msg
view shared model =
    case shared of
        Shared.SettingUp setupModel ->
            Element.column []
                [ Element.text <| "room: " ++ RoomName.print model.room
                , Shared.view setupModel |> Element.map GotSharedMsg
                , Element.Input.button []
                    { onPress = Just <| GotSharedMsg Shared.Validate
                    , label = Element.text "Join"
                    }
                ]

        Shared.Ready { nickname } ->
            Element.column []
                [ Element.text <| "room: " ++ RoomName.print model.room
                , Element.column
                    [ Element.htmlAttribute <| Html.Attributes.class "card-slot" ]
                    [ Element.text <| Nickname.print nickname
                    , model.vote |> Maybe.map Element.text |> Maybe.withDefault Element.none
                    ]
                , Element.column [ Element.htmlAttribute <| Html.Attributes.id "my-deck" ]
                    [ Element.text <| (++) "deck of " <| Nickname.print nickname
                    , displayDeck
                    ]
                ]


displayDeck : Element Msg
displayDeck =
    Element.row [] <| List.map displayCard <| deck


displayCard : String -> Element Msg
displayCard card =
    Element.Input.button []
        { onPress = Just <| Vote card
        , label = Element.text card
        }
