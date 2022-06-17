module Pages.Room exposing (..)

import Effect
import Element exposing (..)
import Element.Input
import RoomName exposing (RoomName)
import Shared
import Theme.Input
import UpdateResult exposing (UpdateResult)



--
-- Init
--


type Stage
    = SelectingNickname String
    | Playing


type alias Model =
    { room : RoomName
    , stage : Stage
    }


init : Shared.Model -> RoomName -> Model
init shared room =
    { room = room
    , stage =
        if shared.nickname == "" then
            SelectingNickname ""

        else
            Playing
    }



--
-- Update
--


type Msg
    = NicknameChanged String
    | Join


update : Shared.Model -> Msg -> Model -> UpdateResult Model
update shared msg model =
    case model.stage of
        Playing ->
            { model = model
            , shared = shared
            , effect = Effect.none
            }

        SelectingNickname currentNickname ->
            case msg of
                NicknameChanged nickname ->
                    { model = { model | stage = SelectingNickname nickname }
                    , shared = shared
                    , effect = Effect.none
                    }

                Join ->
                    { model = { model | stage = Playing }
                    , shared = { shared | nickname = currentNickname }
                    , effect = Effect.none
                    }



--
-- View
--


view : Shared.Model -> Model -> Element Msg
view shared model =
    Element.column []
        [ Element.text <| "room: " ++ RoomName.print model.room
        , case model.stage of
            SelectingNickname nickname ->
                Element.column []
                    [ Theme.Input.text
                        { label = "Nickname"
                        , onChange = NicknameChanged
                        , value = nickname
                        }
                    , Element.Input.button []
                        { label = Element.text "Join"
                        , onPress = Just Join
                        }
                    ]

            _ ->
                Element.text <| "deck of " ++ shared.nickname
        ]
