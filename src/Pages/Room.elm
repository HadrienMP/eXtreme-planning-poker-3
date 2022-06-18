module Pages.Room exposing (..)

import Effect
import Element exposing (..)
import Element.Input
import Lib.NonEmptyString as NES
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
    Element.column []
        [ Element.text <| "room: " ++ RoomName.print model.room
        , case shared of
            Shared.SettingUp setupModel ->
                Element.column []
                    [ Shared.view setupModel |> Element.map GotSharedMsg
                    , Element.Input.button []
                        { onPress = Just <| GotSharedMsg Shared.Validate
                        , label = Element.text "Join"
                        }
                    ]

            Shared.Ready { nickname } ->
                Element.text <| (++) "deck of " <| NES.asString nickname
        ]
