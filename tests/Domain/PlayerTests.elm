module Domain.PlayerTests exposing (..)

import Domain.Nickname as Nickname
import Domain.Player as Player
import Domain.PlayerId as PlayerId
import Expect
import Json.Decode as Decode
import Test exposing (..)
import Utils exposing (..)


all : Test
all =
    describe "Player"
        [ test "serializes and deserializes to the same object" <|
            withMaybe2 ( Nickname.fromString "Jane", PlayerId.create "jane-id" ) <|
                \( nickname, id ) ->
                    { id = id, nickname = nickname }
                        |> Player.json
                        |> Decode.decodeValue Player.decoder
                        |> Expect.equal (Result.Ok { id = id, nickname = nickname })
        ]
