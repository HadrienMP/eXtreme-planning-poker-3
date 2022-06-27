module VoteIOTests exposing (..)

import Domain.Card as Card
import Expect
import VoteIO
import Json.Decode
import Lib.NonEmptyString as NES
import Test exposing (..)


all : Test
all =
    describe "VoteIO"
        [ test "serializes and deserializes to the same object" <|
            withMaybe (NES.create "playerId") <|
                \playerId ->
                    { player = playerId, card = Card.fromString "1" }
                        |> VoteIO.json
                        |> Json.Decode.decodeValue VoteIO.decoder
                        |> Expect.equal (Result.Ok { player = playerId, card = Card.fromString "1" })
        ]


withMaybe : Maybe a -> (a -> Expect.Expectation) -> () -> Expect.Expectation
withMaybe it test _ =
    case it of
        Just b ->
            test b

        Nothing ->
            Expect.fail "Expected a value to start the test"
