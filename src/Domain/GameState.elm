port module Domain.GameState exposing (..)

import Json.Decode as Decode
import Json.Encode as Json
import Domain.RoomMessage exposing (RoomMessage)
import Domain.RoomName as RoomName exposing (RoomName)


port statesOut : RoomMessage -> Cmd msg
port statesIn : (Json.Value -> msg) -> Sub msg


type GameState
    = Choosing
    | Chosen


sendOut : RoomName -> GameState -> Cmd msg
sendOut room =
    json >> RoomMessage (RoomName.print room) >> statesOut


json : GameState -> Json.Value
json state =
    case state of
        Choosing ->
            Json.string "Choosing"

        Chosen ->
            Json.string "Chosen"


decoder : Decode.Decoder GameState
decoder =
    Decode.string
        |> Decode.andThen
            (\raw ->
                case raw of
                    "Chosen" ->
                        Decode.succeed Chosen

                    "Choosing" ->
                        Decode.succeed Choosing

                    _ ->
                        Decode.fail (raw ++ " is not a valid gamestate")
            )
