module Pages.Room exposing (..)

import Effect
import Element exposing (..)
import RoomName exposing (RoomName)
import Shared
import Theme.Input
import UpdateResult exposing (UpdateResult)



--
-- Init
--


type alias Model =
    { room : RoomName }


init : RoomName -> Model
init room =
    { room = room }



--
-- Update
--


type Msg
    = NicknameChanged String


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case msg of
        NicknameChanged nickname ->
            { model = model
            , shared = { shared | nickname = nickname }
            , effect = Effect.none
            }



--
-- View
--


view : Shared.Model -> Model -> Element Msg
view shared model =
    Element.column []
        [ Element.text <| "room: " ++ RoomName.print model.room
        , if shared.nickname == "" then
            Theme.Input.text
                { label = "Nickname"
                , onChange = NicknameChanged
                , value = shared.nickname
                }

          else
            Element.text <| "deck of " ++ shared.nickname
        ]
