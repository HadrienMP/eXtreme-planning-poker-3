module Domain.VoteTests exposing (..)

import Domain.Card as Card
import Domain.PlayerId as PlayerId
import Domain.Vote as Vote
import Expect
import Json.Decode
import Test exposing (..)
import Utils exposing (..)


all : Test
all =
    describe "Vote"
        [ test "serializes and deserializes to the same object" <|
            withMaybe (PlayerId.create "playerId") <|
                \playerId ->
                    { player = playerId, card = Just <| Card.fromString "1" }
                        |> Vote.json
                        |> Json.Decode.decodeValue Vote.decoder
                        |> Expect.equal (Result.Ok { player = playerId, card = Just <| Card.fromString "1" })
        ]
