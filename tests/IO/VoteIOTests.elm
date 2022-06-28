module IO.VoteIOTests exposing (..)

import Domain.Card as Card
import Expect
import IO.VoteIO
import Json.Decode
import Lib.NonEmptyString as NES
import Test exposing (..)
import Utils exposing (..)


all : Test
all =
    describe "VoteIO"
        [ test "serializes and deserializes to the same object" <|
            withMaybe (NES.create "playerId") <|
                \playerId ->
                    { player = playerId, card = Card.fromString "1" }
                        |> IO.VoteIO.json
                        |> Json.Decode.decodeValue IO.VoteIO.decoder
                        |> Expect.equal (Result.Ok { player = playerId, card = Card.fromString "1" })
        ]
