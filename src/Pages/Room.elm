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
            { model = { model | vote = Just card }
            , shared = shared
            , effect = Effect.none
            }



--
-- View
--


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
                    , Element.Input.button [] { onPress = Just <| Vote "1", label = Element.text "1" }
                    , Element.Input.button [] { onPress = Just <| Vote "TFB", label = Element.text "TFB" }
                    , Element.Input.button [] { onPress = Just <| Vote "NFC", label = Element.text "NFC" }
                    ]
                ]
