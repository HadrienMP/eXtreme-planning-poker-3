module Pages.Home exposing (..)

import Effect
import Element exposing (Element)
import Element.Input
import RoomName
import Routes
import Shared
import Theme.Input
import UpdateResult exposing (UpdateResult)



--
-- Init
--


type alias Model =
    { room : String
    , roomError : Bool
    }


init : Model
init =
    { room = ""
    , roomError = False
    }



--
-- Update
--


type Msg
    = GotSharedMsg Shared.Msg
    | RoomNameChanged String
    | Join RoomName.RoomName


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        GotSharedMsg sharedMsg ->
            { model = model
            , shared = Shared.update sharedMsg shared
            , effect = Effect.none
            }

        RoomNameChanged room ->
            { model = { model | room = room }
            , shared = shared
            , effect = Effect.none
            }

        Join room ->
            { model = model
            , shared = Shared.update Shared.Validate shared
            , effect = Effect.pushRoute <| Routes.Room room
            }



--
-- View
--


view : Shared.Model -> Model -> Element Msg
view shared model =
    Element.column []
        [ case shared of
            Shared.SettingUp setupModel ->
                Shared.view setupModel |> Element.map GotSharedMsg

            _ ->
                Element.none
        , Theme.Input.text
            { label = "Room"
            , onChange = RoomNameChanged
            , value = model.room
            }
        , Element.Input.button []
            { onPress =
                model.room
                    |> RoomName.fromString
                    |> Maybe.map Join
            , label = Element.text "Join"
            }
        ]
