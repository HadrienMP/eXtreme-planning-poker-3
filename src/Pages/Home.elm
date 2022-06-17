module Pages.Home exposing (..)

import Effect
import Element exposing (Element)
import RoomName
import Routes
import Shared
import Theme.Input
import UpdateResult exposing (UpdateResult)
import Element.Input



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
    | Join RoomName.RoomName


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        NicknameChanged nickname ->
            { model = model, shared = { shared | nickname = nickname }, effect = Effect.none }

        RoomNameChanged room ->
            { model = { model | room = room }, shared = shared, effect = Effect.none }
        
        Join room ->
            {model = model, shared = shared, effect = Effect.pushRoute <| Routes.Room room}



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
                    Element.Input.button []
                        { onPress = Just <| Join roomName
                        , label = Element.text "Join"
                        }
                )
            |> Maybe.withDefault Element.none
        ]
