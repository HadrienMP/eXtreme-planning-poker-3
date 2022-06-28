module Domain.GameState exposing (..)

import Json.Decode as Decode
import Json.Encode as Json


type GameState
    = Choosing
    | Chosen


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
