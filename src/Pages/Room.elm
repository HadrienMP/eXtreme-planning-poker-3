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
    }


init : Shared.Model -> RoomName -> Model
init _ room =
    { room = room
    }



--
-- Update
--


type Msg
    = GotSharedMsg Shared.Msg


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        GotSharedMsg sharedMsg ->
            { model = model
            , shared = Shared.update sharedMsg shared
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
                    [ Element.text <| Nickname.print nickname ]
                , Element.text <| (++) "deck of " <| Nickname.print nickname
                ]
