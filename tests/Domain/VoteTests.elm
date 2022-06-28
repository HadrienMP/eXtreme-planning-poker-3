module Domain.VoteTests exposing (..)

import Domain.Card as Card
import Domain.Vote as Vote
import Expect
import Json.Decode
import Lib.NonEmptyString as NES
import Test exposing (..)
import Utils exposing (..)


all : Test
all =
    describe "Vote"
        [ test "serializes and deserializes to the same object" <|
            withMaybe (NES.create "playerId") <|
                \playerId ->
                    { player = playerId, card = Card.fromString "1" }
                        |> Vote.json
                        |> Json.Decode.decodeValue Vote.decoder
                        |> Expect.equal (Result.Ok { player = playerId, card = Card.fromString "1" })
        ]
