module Domain.GameStateTests exposing (..)

import Domain.GameState as GameState exposing (GameState(..))
import Expect
import Json.Decode as Decode
import Test exposing (..)


all : Test
all =
    describe "Game State"
        [ test "Choosing - serializes and deserializes to the same object" <|
            \_ ->
                Choosing
                    |> GameState.json
                    |> Decode.decodeValue GameState.decoder
                    |> Expect.equal (Result.Ok Choosing)
        , test "Chosen - serializes and deserializes to the same object" <|
            \_ ->
                Chosen
                    |> GameState.json
                    |> Decode.decodeValue GameState.decoder
                    |> Expect.equal (Result.Ok Chosen)
        ]
