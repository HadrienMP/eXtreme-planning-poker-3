module Pages.Home exposing (..)

import Effect
import Element exposing (Element)
import RoomName
import Routes
import Shared
import Theme.Element
import Theme.Input
import UpdateResult exposing (UpdateResult)



--
-- Init
--


type alias Model =
    { room : String
    }


init : Model
init =
    { room = ""
    }



--
-- Update
--


type Msg
    = NicknameChanged String
    | RoomNameChanged String


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        NicknameChanged nickname ->
            { model = model, shared = { shared | nickname = nickname }, effect = Effect.none }

        RoomNameChanged room ->
            { model = { model | room = room }, shared = shared, effect = Effect.none }



--
-- View
--


view : Shared.Model -> Model -> Element Msg
view shared model =
    Element.column []
        [ Theme.Input.text
            { label = "Nickname"
            , onChange = NicknameChanged
            , value = shared.nickname
            }
        , Theme.Input.text
            { label = "Room"
            , onChange = RoomNameChanged
            , value = model.room
            }
        , model.room
            |> RoomName.fromString
            |> Maybe.map
                (\roomName ->
                    Theme.Element.link
                        { route = Routes.Room roomName
                        , label = "Join"
                        }
                )
            |> Maybe.withDefault Element.none
        ]
