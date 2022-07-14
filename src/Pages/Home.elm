module Pages.Home exposing (..)

import Domain.RoomName exposing (RoomName)
import Effect
import Element exposing (Element, spacing)
import FeatherIcons
import Lib.UpdateResult exposing (UpdateResult)
import Routes
import Shared
import Theme.Input
import Theme.Theme exposing (featherIconToElement, pageWidth)



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
    | Join RoomName


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
            let
                updated =
                    Shared.update Shared.Validate shared
            in
            { model = model
            , shared = updated
            , effect =
                Effect.batch
                    [ Effect.pushRoute <| Routes.Room room
                    , Shared.getPlayer updated
                        |> Maybe.map (Effect.sharePlayer room)
                        |> Maybe.withDefault Effect.none
                    ]
            }



--
-- View
--


view : Shared.Model -> Model -> Element Msg
view shared model =
    Element.column [ spacing 30, pageWidth ]
        [ Theme.Input.textWithIcon
            { label = "Room"
            , onChange = RoomNameChanged
            , value = model.room
            , icon =
                FeatherIcons.box
                    |> featherIconToElement { shadow = True }
            , size = Just 10
            }
        , Shared.getIncomplete shared
            |> Maybe.map (Shared.view >> Element.map GotSharedMsg)
            |> Maybe.withDefault Element.none
        , Theme.Input.buttonWithIcon
            { onPress =
                model.room
                    |> Domain.RoomName.fromString
                    |> Maybe.map Join
            , icon =
                FeatherIcons.send
                    |> featherIconToElement { shadow = False }
            , label = "Join"
            }
        ]
